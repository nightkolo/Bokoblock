extends Node2D
class_name Bokobody

signal has_moved(moved_to: Vector2)
signal has_turned(turned_to: float)
#signal has_undoed()
signal move_end()
signal turn_end()
signal move_stopped()
signal turn_stopped()
signal starpoint_entered(has_entered: bool)
signal child_block_entered_one_col_wall(is_block: Bokoblock)
signal child_block_exited_one_col_wall()

@export_group("Transformation")
@export var movement_strength: int = 1
@export_range(-4, 4) var turning_strength: int = 1
@export var no_move: bool = false
@export var no_turn_delay: bool = false
@export_range(0.0, 1.0, 0.025, "or_greater") var movement_time: float = 0.08
@export_group("Modify")
@export var animator: BokobodyAnimationComponent ## @deprecated
@export var SFX: BokobodyAudio ## @deprecated
@export var auto_assign_sfx_and_animation: bool = true
@export var show_blocks: bool = true
@export var show_light: bool = true
@export var light_scale: Vector2 = Vector2.ONE * 2.8
@export_group("Objects to Assign")
@export var particles_win: PackedScene = preload("res://world/world/particles_bokoblock_stage_complete.tscn")
@export var light_glow: PackedScene = preload("res://world/world/point_light_bokobody_glow.tscn")
@export var audio_node: PackedScene = preload("res://object/game/bokobody_audio_component.tscn")

var transforms_made: Array ## Dynamic array.
var turns_made: Array[float]
var moves_made: Array[Vector2]
var child_blocks: Array[Bokoblock]
var is_on_starpoint: bool
var is_moving: bool:
	get:
		return is_moving
	set(value):
		if !value:
			_has_stopped()
		is_moving = value
var is_actually_turning: bool
var is_turning: bool:
	get:
		return is_turning
	set(value):
		if !value:
			_has_stopped()
		is_turning = value

var _tween_move: Tween
var _tween_turn: Tween
var _current_last_transform
var _can_set_record: bool
var _old_pos: Vector2
var _old_rot: float


func _ready() -> void:
	_setup_node()
	
	if !no_move:
		GameMgr.current_bodies.append(self)
		
		PlayerInput.input_undo.connect(undo)
		PlayerInput.input_move.connect(move)
		PlayerInput.input_turn.connect(turn)
	
	has_moved.connect(_on_transform)
	has_turned.connect(_on_transform)
	#has_undoed.connect(_on_transform)
	move_end.connect(check_state)
	turn_end.connect(check_state)
	
	GameLogic.state_checked.connect(func():
		if GameLogic.we_have_made_a_move:
			
			transforms_made.push_front(_current_last_transform)
			#print_debug(transforms_made)
			
			match typeof(_current_last_transform):
				
				Variant.Type.TYPE_FLOAT:
					turns_made.push_front(_current_last_transform)
					
				Variant.Type.TYPE_VECTOR2:
					moves_made.push_front(_current_last_transform)
		)
	
	if auto_assign_sfx_and_animation:
		var aud := audio_node.instantiate()
		var anim := BokobodyAnimationComponent.new()
		
		add_child(anim)
		add_child(aud)
		
		SFX = aud
		animator = anim
	
	await GameMgr.process_waittime()
	for block: Bokoblock in child_blocks:
		block.area_entered.connect(func(area: Area2D):
			if has_hit_area(area):
				stop_transforming()
			)
		block.body_entered.connect(func(body: Node2D):
			if has_hit_object(body):
				stop_transforming()
			) 
		
		if !show_blocks:
			for sprite: Sprite2D in [block.sprite_block, block.sprite_eyes]:
				sprite.visible = false


func _setup_node() -> void:
	position = position.snapped(Vector2.ONE * GameUtil.TILE_SIZE)
	position -= (Vector2.ONE * GameUtil.TILE_SIZE) / 2.0
	
	if show_light:
		var light: PointLight2D = light_glow.instantiate() as PointLight2D
		light.scale = light_scale
		add_child(light)
		
		var tween: Tween = create_tween().set_loops()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(light,"energy",2.0,2.0)
		tween.tween_property(light,"energy",1.0,2.0)


func check_state() -> void:
	await GameMgr.process_waittime()
	
	var has_stood_on_starpoint: bool = GameLogic.check_if_block_on_starpoint(child_blocks)
	
	if has_stood_on_starpoint && !is_on_starpoint:
		starpoint_entered.emit(has_stood_on_starpoint)
		is_on_starpoint = true
	elif !has_stood_on_starpoint && is_on_starpoint:
		starpoint_entered.emit(has_stood_on_starpoint)
		is_on_starpoint = false

	
func undo() -> void:
	#print_debug(transforms_made)
	
	if transforms_made.is_empty():
		await get_tree().create_timer(0.1).timeout
		GameLogic.body_stopped.emit(self)
		return
	
	var last_move = transforms_made[0]
	#has_undoed.emit()
	
	match typeof(last_move):
		
		TYPE_VECTOR2:
			transforms_made.pop_front()
			await move(last_move * signf(movement_strength) * -1, true, false)
		
		TYPE_FLOAT:
			transforms_made.pop_front()
			await turn(last_move * signf(turning_strength) * -1, true, false)
	
	#print_debug(transforms_made)
	
	GameLogic.body_stopped.emit(self)


func turn(p_turn_to: float, disable_colli: bool = false, set_record: bool = true) -> void:
	if is_turning:
		return
	
	is_turning = true
	is_actually_turning = true
	has_turned.emit(signf(p_turn_to))
	_old_rot = rotation_degrees
	_can_set_record = set_record

	var turn_to: float = GameUtil.BOKOBODY_TURN_DEGREE * signf(p_turn_to) * turning_strength
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
		
	GameUtil.reset_tween(_tween_turn)
	_tween_turn = create_tween()
	_tween_turn.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_turn.tween_property(self,"rotation_degrees",rotation_degrees + turn_to,movement_time*4.0)
	
	await _tween_turn.finished
	
	is_actually_turning = false
	turn_end.emit()
	
	#if set_record:
		#turns_made.push_front(signf(p_turn_to))
		#transforms_made.push_front(signf(p_turn_to))
		
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
	move_end.emit()
	
	#if set_record:
		#moves_made.push_front(p_move_to.sign())
		#transforms_made.push_front(p_move_to.sign())
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(false)


func stop_moving() -> void:
	if !is_moving:
		return
	
	_current_last_transform = Vector2.ZERO
	
	move_stopped.emit()
	GameLogic.body_move_hit.emit()
	
	GameUtil.reset_tween(_tween_move)
	
	position = _old_pos
	
	is_moving = false
	_disable_colli(false)
	
	#if _can_set_record:
		#moves_made.push_front(Vector2.ZERO)
		#transforms_made.push_front(Vector2.ZERO)
	

func stop_turning() -> void:
	if !is_actually_turning:
		return
	
	_current_last_transform = 0.0
	
	turn_stopped.emit()
	GameLogic.body_turn_hit.emit()
	
	if _tween_turn:
		_tween_turn.kill()
	
	_tween_turn = create_tween()
	_tween_turn.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_turn.tween_property(self,"rotation_degrees",_old_rot,movement_time*2.0)
	await _tween_turn.finished
	
	is_actually_turning = false
	_disable_colli(false)
	
	#if _can_set_record:
		#turns_made.push_front(0.0)
		#transforms_made.push_front(0.0)
		
	await _turn_delay()
	normalize_bokobody_rotation()
	is_turning = false


func stop_transforming() -> void:
	stop_moving()
	stop_turning()


func normalize_bokobody_rotation() -> void:
	#var angle: float = BokoMath.normalize_angle(rotation_degrees)
	
	rotation_degrees = BokoMath.round_to_nearest_90(BokoMath.normalize_angle(rotation_degrees))


func is_transforming() -> bool:
	return (is_moving || is_turning)
	
	
func is_transforming_real() -> bool:
	return (is_moving || is_actually_turning)


var is_on_top_switch_block: bool ## @experimental

# It works but it's so hacky...
func has_hit_area(area: Area2D) -> bool:
	if is_on_top_switch_block:
		return area is Bokoblock
	else:
		return area is Bokoblock || area is SwitchBlocks
		

func has_hit_object(body: Node2D) -> bool:
	return body is TileMapLayer || body is SleepingBlock


func get_current_last_transform():
	return _current_last_transform


func get_normalized_rotation_degrees() -> float:
	return BokoMath.normalize_angle(rotation_degrees)


func get_current_turn() -> int:
	return BokoMath.simplify_angle(rotation_degrees) + 1


func _has_stopped() -> void:
	# Await used due to routine issues
	
	await get_tree().create_timer(0.04).timeout
	GameLogic.body_stopped.emit(self)


func _on_transform(trans_to = &"UNDO") -> void:
	_current_last_transform = trans_to
	
	
func _turn_delay() -> void:
	if no_turn_delay:
		await get_tree().create_timer(0.0).timeout
	else:
		await get_tree().create_timer(movement_time*1.75).timeout


func _disable_colli(disable: bool) -> void:
	for block: Bokoblock in child_blocks:
		block.collision.set_deferred("disabled", disable)
