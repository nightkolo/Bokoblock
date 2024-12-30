## Under construction
extends Node2D
class_name Bokobody

# TODO: functions turn, move need a rework.
signal moved(moved_to: Vector2)
signal turned(turned_to: float)
signal move_end(has_moved_by: Vector2)
signal turn_end(has_turned_by: float)
signal move_stopped()
signal turn_stopped()
signal child_block_has_entered_one_way_block(is_block: Bokoblock)
signal child_blocks_left_one_way_block()

@export var movement_strength: int = 1 ## How many grid it'll move.
@export var rotation_strength: int = 1 ## How many turns it'll move.
@export_group("Modify")
@export var movement_time: float = 0.1 ## Movement time.
@export var just_dont: bool = false ## Don't, okay?

var moves_made: Array[Variant] ## An [Array] of the Bokobody's transformation history.
var child_blocks: Array[Bokoblock] ## An [Array] of child [Bokoblock] nodes. Assigned at runtime.
var is_moving: bool: ## Returns [code]true[/code] if [Bokobody2D] is currently moving, [code]false[/code] if otherwise.
	set(value):
		is_moving = value
		if !value:
			GameLogic.bokobody_stopped.emit(self)
var is_rotating: bool: ## Returns [code]true[/code] if [Bokobody2D] is currently turning, [code]false[/code] if otherwise.
	set(value):
		is_rotating = value
		if !value:
			GameLogic.bokobody_stopped.emit(self)

## Tile size.
const TILE_SIZE = 45.0 

var _tween_move: Tween
var _tween_rot: Tween
var _tween_one_col_anim: Tween
var _can_set_record: bool
var _old_pos: Vector2
var _old_rot: float



func _ready() -> void:
	if just_dont:
		print_rich("[font_size=25.0][wave amp=50.0 freq=5.0 connected=1][color=green][b]Fart Fart Fart")
	
	GameMgr.current_bodies.append(self as Bokobody)
	
	child_block_has_entered_one_way_block.connect(anim_blocks_went_through_one_col_block)
		
	child_blocks_left_one_way_block.connect(anim_blocks_went_out_one_col_block)
	
	for child: Node in get_children():
		if child is Bokoblock:
			child_blocks.append(child as Bokoblock)
			
			(child as Area2D).area_entered.connect(func(area: Area2D):
				if area is Bokoblock:
					stop_making_move()
				)
			(child as Area2D).body_entered.connect(func(body: Node2D):
				if (body is TileMapLayer || body is SleepingBlock):
					stop_making_move()
				)
	
	position = position.snapped(Vector2.ONE * GameUtil.get_tile_size()) 
	position += (Vector2.ONE * GameUtil.get_tile_size()) / 2
	
	PlayerInput.input_undo.connect(undo)
	PlayerInput.input_move.connect(move)
	PlayerInput.input_turn.connect(turn)


func _process(_delta: float) -> void:
	if rotation_degrees > 360.0: # ehh?
		rotation_degrees += -360.0
	elif rotation_degrees < -360.0:
		rotation_degrees += 360.0


## Undos previous moves.
func undo() -> void:
	if moves_made.is_empty():
		await get_tree().create_timer(0.1).timeout
		GameLogic.bokobody_stopped.emit(self)
		return
	
	var last_move = moves_made[0]
	
	match typeof(last_move):
	
		TYPE_VECTOR2:
			moves_made.pop_front()
			await move(last_move * -1, true, false)
			
		TYPE_FLOAT:
			moves_made.pop_front()
			await turn(last_move * 90.0 * -1, true, false)
			
	GameLogic.bokobody_stopped.emit(self)


## @experimental
## Turns [Bokobody2D]. [br][br][param disable_colli] disables [Bokobody2D] collision during the turn. [param set_record] pushes the turn record to [member moves_made].
func turn(rotate_deg_to: float, disable_colli: bool = false, set_record: bool = true) -> void:
	var rot_to := deg_to_rad(rotate_deg_to) * rotation_strength
	_old_rot = rotation
	_can_set_record = set_record
	
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
		
	turned.emit(sign(rotate_deg_to))
	
	is_rotating = true
	_tween_rot = get_tree().create_tween()
	_tween_rot.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_rot.tween_property(self,"rotation",rotation + rot_to,movement_time)
	
	await _tween_rot.finished
	await get_tree().create_timer(movement_time).timeout
	
	turn_end.emit(sign(rotate_deg_to))
	if set_record:
		moves_made.push_front(sign(rot_to))
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(false)
	is_rotating = false
	

## @experimental
## Moves [Bokobody2D]. [br][br][param disable_colli] disables [Bokobody2D] collision during the move. [param set_record] pushes the move record to [member moves_made].
func move(direction: Vector2, disable_colli: bool = false, set_record: bool = true) -> void:
	var move_to: Vector2 = GameUtil.get_tile_size() * direction * movement_strength
	_old_pos = position
	_can_set_record = set_record
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(true)
		
	moved.emit(direction)
	
	is_moving = true
	_tween_move = get_tree().create_tween()
	_tween_move.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_move.tween_property(self,"position",position + move_to,movement_time)
	
	await _tween_move.finished
	await get_tree().create_timer(movement_time).timeout
	
	move_end.emit(direction)
	if set_record:
		moves_made.push_front(sign(move_to))
	if disable_colli: # Doing a check to avoid runtime slowdown
		_disable_colli(false)
	is_moving = false


## Stops current [Bokobody2D] movement, and returns to previous position.[br][br] This function is called by [signal Bokoblock.area_entered], [signal Bokoblock.body_entered].
func stop_moving() -> void:
	if _tween_move:
		_tween_move.kill()
	
	move_stopped.emit()
	position = _old_pos
	
	if _can_set_record:
		moves_made.push_front(Vector2.ZERO)
	_disable_colli(false)
	is_moving = false
	

## Stops current [Bokobody2D] rotation, and returns to previous position.[br][br]
## This function is called by [signal Bokoblock.area_entered], [signal Bokoblock.body_entered].
func stop_turning() -> void:
	if _tween_rot:
		_tween_rot.kill()
	
	turn_stopped.emit()
	
	_tween_rot = create_tween()
	_tween_rot.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween_rot.tween_property(self,"rotation",_old_rot,movement_time*2.0)
	await _tween_rot.finished
	
	if _can_set_record:
		moves_made.push_front(0.0)
	_disable_colli(false)
	is_rotating = false


func anim_blocks_went_through_one_col_block(is_block: Bokoblock) -> void:
	var dur := 1.0
	
	if _tween_one_col_anim:
		_tween_one_col_anim.kill()
		
	_tween_one_col_anim = create_tween().set_parallel(true)
	_tween_one_col_anim.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	for block: Bokoblock in child_blocks:
		block.sprite_block.self_modulate = GameLogic.set_boko_color(is_block.boko_color)
		block.sprite_node_1.scale = Vector2.ONE / 4.0
		block.anim_ghost()
		
		_tween_one_col_anim.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)
	
	
func anim_blocks_went_out_one_col_block() -> void:
	var dur := 0.45
	
	if _tween_one_col_anim:
		_tween_one_col_anim.kill()
		
	_tween_one_col_anim = create_tween().set_parallel(true)
	_tween_one_col_anim.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	for block: Bokoblock in child_blocks:
		block.sprite_block.self_modulate = GameLogic.set_boko_color(block.boko_color)
		block.sprite_node_1.scale = Vector2.ONE * 1.4
		
		_tween_one_col_anim.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)


## Returns [member moves_made].
func get_tranformation_history() -> Array:
	return moves_made


## Returns [code]true[/code] if [Bokobody2D] is not making a move/turn, [code]false[/code] if otherwise.
func is_idle() -> bool:
	return !(is_moving || is_rotating)


## Returns [code]true[/code] if [Bokobody2D] is making a move/turn (transform), [code]false[/code] if otherwise.[br][br] Similar to [method is_idle] but reversed.
func is_transforming() -> bool:
	return (is_moving || is_rotating)


func stop_making_move() -> void:
	if is_moving:
		stop_moving()
		
	if is_rotating:
		stop_turning()
	
	
func _disable_colli(disable: bool) -> void:
	for block: Area2D in child_blocks:
		(block.get_node("CollisionShape2D") as CollisionShape2D).set_deferred("disabled", disable)
	
	
