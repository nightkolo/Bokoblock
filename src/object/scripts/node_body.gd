extends Node2D
class_name Bokobody

signal has_tranformed(trans_to: Variant)
signal has_moved(moved_to: Vector2)
signal has_turned(turned_to: float)
signal move_end(has_moved_by: Vector2)
signal turn_end(has_turned_by: float)
signal move_stopped()
signal turn_stopped()
signal turn_full_stopped()
signal child_block_entered_one_col_block(is_block: Bokoblock)
signal child_blocks_exited_one_col_block()

@export var movement_strength: int = 1
@export var turning_strength: int = 1
@export_group("Modify")
## @experimental: Due to how the game is developed, [member no_turn_delay] can't be achieved without bugs.
## Removes artificial turn delay to handle over-turning, and avoid glitches.
@export var no_turn_delay: bool = false
@export var no_move: bool = false
@export var movement_time: float = 0.1
@export var show_blocks: bool = true
@export var show_light: bool = true
@export var light_scale: Vector2 = Vector2.ONE * 2.8
@export_subgroup("...")
## @deprecated: I should probably remove this extremely useless property, but I can't because... it's very a legacy property.
## For the funny.
@export var just_dont: bool = false
@export_group("Objects to Assign")
@export var particles_win: PackedScene = preload("res://world/world/particles_bokoblock_stage_complete.tscn")
@export var light_glow: PackedScene = preload("res://world/world/point_light_bokobody_glow.tscn")

var current_last_transform: Variant ## @experimental
var transforms_made: Array[Variant]
var turns_made: Array[float]
var moves_made: Array[Vector2]
var child_blocks: Array[Bokoblock]
var is_moving: bool:
	set(value):
		is_moving = value
		if !value:
			GameLogic.bokobody_stopped.emit(self)
var is_actually_turning: bool
var is_turning: bool:
	set(value):
		is_turning = value
		if !value:
			GameLogic.bokobody_stopped.emit(self)

const TILE_SIZE = 45.0 ## @deprecated

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
	child_block_entered_one_col_block.connect(anim_blocks_entered_one_col_wall)
	child_blocks_exited_one_col_block.connect(anim_blocks_exited_one_col_wall)
	
	if !no_move:
		PlayerInput.input_undo.connect(undo)
		PlayerInput.input_move.connect(move)
		PlayerInput.input_turn.connect(turn)
	else:
		# Bruh.
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
	turn_full_stopped.connect(normalize_bokobody_rotation)
	
	await get_tree().create_timer(0.1).timeout
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
	
	if just_dont:
		print_rich("[font_size=25.0][wave amp=50.0 freq=5.0 connected=1][color=green][b]Fart Fart Fart")


func _set_rotation_values() -> void:
	@warning_ignore("narrowing_conversion")
	_current_turn = BokoMath.simplify_angle(rotation_degrees) + 1
	_normalized_rotation_degrees = BokoMath.normalize_angle(rotation_degrees)
	

func undo() -> void:
	if transforms_made.is_empty():
		await get_tree().create_timer(0.1).timeout
		GameLogic.bokobody_stopped.emit(self)
		return
	
	var last_move = transforms_made[0]
	
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
	
	# TODO: Come to think of it, use rotation_degrees instead of rotation for turning

	var turn_to := deg_to_rad(GameUtil.BOKOBODY_TURN_DEGREE * sign(p_turn_to) * turning_strength)
	
	_old_rot = rotation
	_can_set_record = set_record
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
	
	_tween_rot = get_tree().create_tween()
	_tween_rot.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_rot.tween_property(self,"rotation",rotation + turn_to,movement_time)
	
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
	turn_full_stopped.emit()


func move(p_move_to: Vector2, disable_colli: bool = false, set_record: bool = true) -> void:
	if is_moving:
		return
	
	is_moving = true
	has_moved.emit(p_move_to.sign())
	
	var move_to: Vector2 = GameUtil.TILE_SIZE * p_move_to.sign() * movement_strength
	
	_old_pos = position
	_can_set_record = set_record
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
	
	_tween_move = get_tree().create_tween()
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
	
	if _tween_move:
		_tween_move.kill()
	
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
	turn_full_stopped.emit()
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
	
	if _tween_one_col_anim:
		_tween_one_col_anim.kill()
		
	_tween_one_col_anim = create_tween().set_parallel(true)
	_tween_one_col_anim.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	for block: Bokoblock in child_blocks:
		block.sprite_block.self_modulate = GameUtil.set_boko_color(is_block.boko_color)
		block.sprite_node_1.scale = Vector2.ONE / 4.0
		block.anim_ghost()
		
		_tween_one_col_anim.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)
	
	
func anim_blocks_exited_one_col_wall() -> void:
	var dur := 0.45
	
	if _tween_one_col_anim:
		_tween_one_col_anim.kill()
		
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
	has_tranformed.emit(trans_to)
	current_last_transform = trans_to


func _turn_delay() -> void:
	if no_turn_delay:
		await get_tree().create_timer(0.0).timeout
	else:
		await get_tree().create_timer(movement_time*2.0).timeout


func _disable_colli(disable: bool) -> void:
	for block: Bokoblock in child_blocks:
		block.collision.set_deferred("disabled", disable)
