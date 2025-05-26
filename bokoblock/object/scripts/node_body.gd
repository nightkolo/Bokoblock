extends Node2D
class_name Bokobody

signal has_moved(moved_to: Vector2)
signal has_turned(turned_to: float)
signal move_end()
signal turn_end()
signal move_stopped()
signal turn_stopped()
signal starpoint_entered(has_entered: bool)
signal child_block_entered_one_col_wall(is_block: Bokoblock)
signal child_block_exited_one_col_wall()

@export var movement_strength: int = 1
@export_range(-4, 4) var turning_strength: int = 1
@export_group("Modify")
@export var animator: BokobodyAnimationComponent
@export var auto_assign_animation: bool = true
@export var show_blocks: bool = true
@export var show_light: bool = true
@export var no_move: bool = false
@export_group("Objects to Assign")
@export var light_glow: PackedScene = preload("res://world/world/point_light_bokobody_glow.tscn")

var movement_time: float = 0.08 ## Causes issues when movement time is too small
var child_blocks: Array[Bokoblock]
#var is_on_starpoint: bool
var is_moving: bool:
	get:
		return is_moving
	set(value):
		if !value:
			_has_stopped()
		is_moving = value
var is_turning: bool:
	get:
		return is_turning
	set(value):
		if !value:
			_has_stopped()
		is_turning = value
var is_on_one_way_wall: bool:
	get:
		return is_on_one_way_wall
	set(value):
		if value && !GameLogic.state_checked.is_connected(_on_one_way_wall):
			GameLogic.state_checked.connect(_on_one_way_wall)
		is_on_one_way_wall = value
var is_one_way_wall: OneColorWalls

var _tween_move: Tween
var _tween_turn: Tween
var _current_last_transform
var _old_pos: Vector2
var _old_rot: float


func _ready() -> void:
	_setup_node()
	
	if !no_move:
		GameLogic.current_bodies.append(self)
		
		PlayerInput.input_move.connect(move)
		PlayerInput.input_turn.connect(turn)
	
	has_moved.connect(_on_transform)
	has_turned.connect(_on_transform)
	
	if auto_assign_animation:
		var anim := BokobodyAnimationComponent.new()
		add_child(anim)
		animator = anim
	
	await get_tree().create_timer(0.05).timeout
	for block: Bokoblock in child_blocks:
		block.area_entered.connect(func(area: Area2D):
			if area is Bokoblock:
				stop_transforming()
			)
		block.body_entered.connect(func(body: Node2D):
			if body is TileMapLayer || body is SleepingBlock:
				stop_transforming()
			) 
		
		if !show_blocks:
			for sprite: Sprite2D in [block.sprite_block, block.sprite_eyes]:
				sprite.visible = false


func _setup_node() -> void:
	position = position.snapped(Vector2.ONE * GameUtil.TILE_SIZE)
	position -= (Vector2.ONE * GameUtil.TILE_SIZE) / 2.0
	
	if show_light:
		await get_tree().create_timer(0.1).timeout
		
		var light: PointLight2D = light_glow.instantiate() as PointLight2D
		light.scale = Vector2.ONE * 2.8
		add_child(light)
		
		var tween: Tween = create_tween().set_loops()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(light,"energy",2.0,2.0)
		tween.tween_property(light,"energy",1.0,2.0)


#func check_state() -> void:
	#await GameMgr.process_waittime()
	#
	#var has_stood_on_starpoint: bool = GameLogic.check_if_block_on_starpoint(child_blocks)
	#
	#if has_stood_on_starpoint && !is_on_starpoint:
		#starpoint_entered.emit(has_stood_on_starpoint)
		#is_on_starpoint = true
	#elif !has_stood_on_starpoint && is_on_starpoint:
		#starpoint_entered.emit(has_stood_on_starpoint)
		#is_on_starpoint = false


## [param disable_colli] is expermental.
func turn(p_turn_to: float, disable_colli: bool = false) -> void:
	if is_turning:
		return
	
	is_turning = true
	has_turned.emit(signf(p_turn_to))
	_old_rot = rotation_degrees

	var turn_to: float = 90.0 * signf(p_turn_to) * turning_strength
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
		
	GameUtil.reset_tween(_tween_turn)
	_tween_turn = create_tween()
	_tween_turn.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween_turn.tween_property(self,"rotation_degrees",rotation_degrees + turn_to,0.3)
	
	await _tween_turn.finished
	
	turn_end.emit()
		
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(false)
	
	#await _turn_delay()
	is_turning = false
	normalize_bokobody_rotation()


## [param disable_colli] is expermental.
func move(p_move_to: Vector2, disable_colli: bool = false) -> void:
	if is_moving:
		return
		
	is_moving = true
	has_moved.emit(p_move_to.sign())
	_old_pos = position
	
	for block: Bokoblock in child_blocks:
		if block.wall_detect(p_move_to):
			stop_moving()
			return
	
	var move_to: Vector2 = p_move_to.sign() * GameUtil.TILE_SIZE * movement_strength
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
	
	GameUtil.reset_tween(_tween_move)
	_tween_move = create_tween()
	_tween_move.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_move.tween_property(self,"position",position + move_to,movement_time)
	
	await _tween_move.finished
	
	is_moving = false
	move_end.emit()
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(false)


func stop_moving() -> void:
	if !is_moving:
		return

	move_stopped.emit()
	GameLogic.body_hit_move.emit()
	
	GameUtil.reset_tween(_tween_move)
	
	position = _old_pos
	
	is_moving = false
	#_disable_colli(false)
	

func stop_turning() -> void:
	if !is_turning:
		return
	
	turn_stopped.emit()
	GameLogic.body_hit_turn.emit()
	
	if _tween_turn:
		_tween_turn.kill()
	
	_tween_turn = create_tween()
	_tween_turn.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_turn.tween_property(self,"rotation_degrees",_old_rot,0.06)
	await _tween_turn.finished
	
	#_disable_colli(false)
	
	normalize_bokobody_rotation()
	is_turning = false


func check_if_exited(blocks: Array[Bokoblock]) -> bool:
	for block: Bokoblock in blocks:
		if is_one_way_wall in block.get_overlapping_areas():
			return true
			
	return false


func _on_one_way_wall(_have_moved: bool) -> void:
	is_on_one_way_wall = check_if_exited(child_blocks)

	if !is_on_one_way_wall:
		var index_to_rem := is_one_way_wall.bodies_entered.find(self)
		
		is_one_way_wall.bodies_entered.remove_at(index_to_rem)
		is_one_way_wall = null
		child_block_exited_one_col_wall.emit()
		Audio.one_color_wall_exit.play()
		
		GameLogic.state_checked.disconnect(_on_one_way_wall)


func stop_transforming() -> void:
	stop_moving()
	stop_turning()


func normalize_bokobody_rotation() -> void:
	rotation_degrees = BokoMath.round_to_nearest_90(BokoMath.normalize_angle(rotation_degrees))


func is_transforming() -> bool:
	return (is_moving || is_turning)


var is_on_top_switch_block: bool ## @deprecated

# It works but it's so hacky...
func has_hit_area(area: Area2D) -> bool: ## @deprecated
	if is_on_top_switch_block:
		return area is Bokoblock
	else:
		return area is Bokoblock || area is SwitchBlocks
		

func has_hit_object(body: Node2D) -> bool: ## @deprecated
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


func _on_transform(trans_to) -> void:
	_current_last_transform = trans_to


func _disable_colli(disable: bool) -> void: ## @experimental
	for block: Bokoblock in child_blocks:
		if block.get_node_or_null("CollisionShape2D"):
			block.get_node_or_null("CollisionShape2D").set_deferred("disabled", disable)
