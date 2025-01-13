extends Node2D
class_name Bokobody

signal has_moved(moved_to: Vector2)
signal has_turned(turned_to: float)
signal move_end(has_moved_by: Vector2)
signal turn_end(has_turned_by: float)
signal move_stopped()
signal turn_stopped()
signal starpoint_entered(entered: bool)
signal child_block_entered_one_col_wall(is_block: Bokoblock)
signal child_block_exited_one_col_wall()

@export var movement_strength: int = 1
@export var turning_strength: int = 1
@export_group("Modify")
@export var no_turn_delay: bool = false
@export var no_move: bool = false
@export var movement_time: float = 0.1
@export var show_blocks: bool = true
@export var show_light: bool = true
@export var light_scale: Vector2 = Vector2.ONE * 2.8
@export_group("Objects to Assign")
@export var particles_win: PackedScene = preload("res://world/world/particles_bokoblock_stage_complete.tscn")
@export var light_glow: PackedScene = preload("res://world/world/point_light_bokobody_glow.tscn")

var current_last_transform: Variant ## Used for [method Bokoblock.anim_hit_block].
var transforms_made: Array ## Dynamic array.
var turns_made: Array[float]
var moves_made: Array[Vector2]
var child_blocks: Array[Bokoblock]
var is_on_starpoint: bool
var is_moving: bool:
	set(value):
		_has_stopped(value)
		is_moving = value
var is_actually_turning: bool
var is_turning: bool:
	set(value):
		_has_stopped(value)
		is_turning = value

var _normalized_rotation_degrees: float
var _current_turn: int
var _tween_move: Tween
var _tween_rot: Tween
var _tween_one_col_anim: Tween
var _can_set_record: bool
var _old_pos: Vector2
var _old_rot: float


func _ready() -> void:
	_setup_node()
	
	GameMgr.current_bodies.append(self)
	
	GameLogic.stage_won.connect(anim_complete)
	
	child_block_entered_one_col_wall.connect(anim_blocks_entered_one_col_wall)
	child_block_exited_one_col_wall.connect(anim_blocks_exited_one_col_wall)
	
	if !no_move:
		PlayerInput.input_undo.connect(undo)
		PlayerInput.input_move.connect(move)
		PlayerInput.input_turn.connect(turn)
	else:
		PlayerInput.input_undo.connect(func():
			await get_tree().create_timer(movement_time).timeout
			GameLogic.bokobody_stopped.emit(self)
			)
		PlayerInput.input_move.connect(func(_move_to: Vector2):
			await get_tree().create_timer(movement_time).timeout
			GameLogic.bokobody_stopped.emit(self)
			)
		PlayerInput.input_turn.connect(func(_turn_to: float):
			await get_tree().create_timer(movement_time).timeout
			GameLogic.bokobody_stopped.emit(self)
			)
	
	has_moved.connect(_on_transform)
	has_turned.connect(_on_transform)
	
	await GameMgr.process_waittime()
	for block: Bokoblock in child_blocks:
		if !show_blocks:
			for sprite: Sprite2D in [block.sprite_block, block.sprite_eyes]:
				sprite.visible = false
		
		block.area_entered.connect(func(area: Area2D):
			if area is Bokoblock:
				stop_transforming()
			)
		block.body_entered.connect(func(body: Node2D):
			if (body is TileMapLayer || body is SleepingBlock):
				stop_transforming()
			) 


func _process(_delta: float) -> void:
	_set_rotation_values()


func _setup_node() -> void:
	position = position.snapped(Vector2.ONE * GameUtil.TILE_SIZE)
	position += (Vector2.ONE * GameUtil.TILE_SIZE) / 2.0
	
	if show_light:
		var light := light_glow.instantiate() as PointLight2D
		light.scale = light_scale
		add_child(light)
		
		var tween := create_tween().set_loops()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(light,"energy",2.0,2.0)
		tween.tween_property(light,"energy",1.0,2.0)


func _set_rotation_values() -> void:
	@warning_ignore("narrowing_conversion")
	_current_turn = BokoMath.simplify_angle(rotation_degrees) + 1
	_normalized_rotation_degrees = BokoMath.normalize_angle(rotation_degrees)


func check_state() -> void:
	await GameMgr.process_waittime()
	
	var has_stood_on_starpoint := GameLogic.check_if_block_on_starpoint(child_blocks)
	
	if has_stood_on_starpoint && !is_on_starpoint:
		is_on_starpoint = true
		starpoint_entered.emit(has_stood_on_starpoint)
	elif !has_stood_on_starpoint && is_on_starpoint:
		is_on_starpoint = false
		starpoint_entered.emit(has_stood_on_starpoint)

	
func undo() -> void:
	if transforms_made.is_empty():
		await get_tree().create_timer(0.1).timeout
		GameLogic.bokobody_stopped.emit(self)
		return
	
	var last_move = transforms_made[0] # dynamic.
	
	match typeof(last_move):
	
		TYPE_VECTOR2:
			transforms_made.pop_front()
			await move(last_move * -1, true, false)
			
		TYPE_FLOAT:
			transforms_made.pop_front()
			await turn(last_move * -1, true, false)
			
	GameLogic.bokobody_stopped.emit(self)


func turn(p_turn_to: float, disable_colli: bool = false, set_record: bool = true) -> void:
	if is_turning:
		return
	
	is_turning = true
	is_actually_turning = true
	has_turned.emit(sign(p_turn_to))
	_old_rot = rotation
	_can_set_record = set_record

	var turn_to: float = GameUtil.BOKOBODY_TURN_DEGREE * sign(p_turn_to) * turning_strength
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
	GameUtil.reset_tween(_tween_rot)
	_tween_rot = create_tween()
	_tween_rot.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_rot.tween_property(self,"rotation_degrees",rotation_degrees + turn_to,movement_time*2.0)
	
	await _tween_rot.finished
	
	is_actually_turning = false
	turn_end.emit(sign(p_turn_to))
	
	if set_record:
		turns_made.push_front(sign(p_turn_to))
		transforms_made.push_front(sign(p_turn_to))
		
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(false)
	
	await _turn_delay()
	is_turning = false
	normalize_bokobody_rotation()


func move(p_move_to: Vector2, disable_colli: bool = false, set_record: bool = true) -> void:
	if is_moving:
		return
	
	is_moving = true
	has_moved.emit(p_move_to.sign())
	_old_pos = position
	_can_set_record = set_record
	
	var move_to: Vector2 = GameUtil.TILE_SIZE * p_move_to.sign() * movement_strength
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
	
	GameUtil.reset_tween(_tween_move)
	_tween_move = create_tween()
	_tween_move.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_move.tween_property(self,"position",position + move_to,movement_time)
	
	await _tween_move.finished
	
	is_moving = false
	move_end.emit(p_move_to.sign())
	
	if set_record:
		moves_made.push_front(sign(p_move_to))
		transforms_made.push_front(sign(p_move_to))
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(false)


func stop_moving() -> void:
	move_stopped.emit()
	
	GameUtil.reset_tween(_tween_move)
	
	is_moving = false
	_disable_colli(false)
	
	position = _old_pos
	
	if _can_set_record:
		moves_made.push_front(Vector2.ZERO)
		transforms_made.push_front(Vector2.ZERO)
	

func stop_turning() -> void:
	turn_stopped.emit()
	
	if _tween_rot:
		_tween_rot.kill()
	
	_tween_rot = create_tween()
	_tween_rot.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_rot.tween_property(self,"rotation",_old_rot,movement_time*2.0)
	await _tween_rot.finished
	
	is_actually_turning = false
	_disable_colli(false)
	
	if _can_set_record:
		turns_made.push_front(0.0)
		transforms_made.push_front(0.0)
		
	await _turn_delay()
	normalize_bokobody_rotation()
	is_turning = false


func stop_transforming() -> void:
	if is_moving:
		stop_moving()
		
	if is_actually_turning:
		stop_turning()


func normalize_bokobody_rotation() -> void:
	var angle := BokoMath.normalize_angle(rotation_degrees)
	rotation_degrees = BokoMath.round_to_nearest_90(angle)


func anim_blocks_entered_one_col_wall(is_block: Bokoblock) -> void:
	var dur := 1.0
	
	GameUtil.reset_tween(_tween_one_col_anim)
		
	_tween_one_col_anim = create_tween().set_parallel(true)
	_tween_one_col_anim.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	for block: Bokoblock in child_blocks:
		block.sprite_block.self_modulate = GameUtil.set_boko_color(is_block.boko_color)
		block.sprite_node_1.scale = Vector2.ONE / 4.0
		block.anim_ghost()
		
		_tween_one_col_anim.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)
	
	
func anim_blocks_exited_one_col_wall() -> void:
	var dur := 0.45
	
	GameUtil.reset_tween(_tween_one_col_anim)
		
	_tween_one_col_anim = create_tween().set_parallel(true)
	_tween_one_col_anim.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	for block: Bokoblock in child_blocks:
		block.sprite_block.self_modulate = GameUtil.set_boko_color(block.boko_color)
		block.sprite_node_1.scale = Vector2.ONE * 1.4
		
		_tween_one_col_anim.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)


func anim_complete() -> void:
	var _tween: Tween
	
	if particles_win:
		var p := particles_win.instantiate() as CPUParticles2D
		add_child(p)
		p.global_rotation = 0.0
		p.emitting = true
		_tween = create_tween()
		_tween.tween_property(p,"self_modulate",Color(Color.WHITE,0.0),p.lifetime/2.0).set_delay(p.lifetime/2.0)


func is_transforming() -> bool:
	return (is_moving || is_turning)
	
	
func is_transforming_real() -> bool:
	return (is_moving || is_actually_turning)


func get_normalized_rotation_degrees() -> float:
	return _normalized_rotation_degrees


func get_current_turn() -> int:
	return _current_turn


func _on_transform(trans_to: Variant) -> void:
	current_last_transform = trans_to


func _has_stopped(not_stopped: bool = false) -> void:
	if not_stopped:
		return
	
	check_state()
	GameLogic.bokobody_stopped.emit(self)


func _turn_delay() -> void:
	if no_turn_delay:
		await get_tree().create_timer(0.0).timeout
	else:
		await get_tree().create_timer(movement_time*2.0).timeout


func _disable_colli(disable: bool) -> void:
	for block: Bokoblock in child_blocks:
		block.collision.set_deferred("disabled", disable)
