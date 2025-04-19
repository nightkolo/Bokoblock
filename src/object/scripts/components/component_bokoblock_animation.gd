extends Node
class_name BokoblockAnimationComponent

@export_group("Assets")
@export var asset_eye_close: Texture2D = preload("res://assets/objects/block-eye-close.png")
@export var asset_eye_happy: Texture2D = preload("res://assets/objects/block-eyes-v03-happy-white.png")

@onready var block: Bokoblock = get_parent() as Bokoblock

var tween_pulse: Tween
var tween_eyes: Tween
var tween_move: Tween
var tween_turn: Tween
var tween_hit_block: Tween
var tween_ghosts: Tween
var tween_starpoint: Tween
var tween_bokocolor: Tween ## @experimental

var _is_being_removed: bool = false


func _ready() -> void:
	if !(block is Bokoblock):
		push_error("%s is not a child of Bokoblock." % str(self))
		return
	
	GameLogic.stage_won.connect(anim_complete)
	
	block.starpoint_entered.connect(anim_landed_starpoint)
	
	await GameMgr.process_waittime()
	if block.parent_bokobody:
		block.parent_bokobody.has_moved.connect(func(moved_to: Vector2):
			block.particles_dust.direction = moved_to * -1
			
			anim_move(moved_to)
			)
		block.parent_bokobody.has_turned.connect(anim_turn)
		block.parent_bokobody.move_stopped.connect(stop_anim_move)
		
		block.body_entered.connect(func(body: Node2D):
			if (body is TileMapLayer || body is SleepingBlock):
				anim_hit_block(block.parent_bokobody.get_current_last_transform())
			)


func anim_turn(turned_by: float, pulse: bool = true) -> void:
	var dur: float = 10.0
	var wobble_to: float = deg_to_rad(20.0) * signf(turned_by)
	
	if block.parent_bokobody:
		dur = block.parent_bokobody.movement_time * 8.0
	
	block.sprite_block.skew = wobble_to
	
	if pulse:
		anim_pulse()
	
	GameUtil.reset_tween(tween_turn)
	tween_turn = create_tween()
	tween_turn.set_ease(Tween.EASE_OUT)
	tween_turn.tween_property(block.sprite_block,"skew",0.0,dur).set_trans(Tween.TRANS_ELASTIC)
	
	
func anim_move(moved_to: Vector2, p_anim_eyes: bool = true) -> void:
	var anim_to: Vector2
	var dur: float = 0.5
	var high := 1.25
	var low := 0.75
	var squash: float
	var stretch: float
	
	if block.parent_bokobody:
		match block.parent_bokobody.get_current_turn():
			1, 3:
				squash = low
				stretch = high
			2, 4:
				squash = high
				stretch = low
	else:
		squash = low
		stretch = high

	match moved_to:
		Vector2.RIGHT, Vector2.LEFT:
			anim_to = Vector2(stretch,squash)
		Vector2.UP, Vector2.DOWN:
			anim_to = Vector2(squash,stretch)
		_:
			anim_to = Vector2.ONE
	
	if p_anim_eyes:
		anim_eyes(moved_to)
	
	GameUtil.reset_tween(tween_move)
	tween_move = create_tween()
	tween_move.set_ease(Tween.EASE_OUT)
	tween_move.tween_property(block.sprite_node_2,"scale",anim_to,dur/6.0)
	tween_move.tween_property(block.sprite_node_2,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)


func stop_anim_move() -> void:
	GameUtil.reset_tween(tween_move)
	
	block.sprite_node_2.scale = Vector2.ONE
	

func anim_eyes(moved_to: Vector2) -> void:
	if block.parent_bokobody == null:
		return

	var move_eyes_to := 7.0

	block.sprite_eyes.global_position += (moved_to as Vector2) * move_eyes_to
	
	GameUtil.reset_tween(tween_eyes)
	tween_eyes = create_tween()
	tween_eyes.tween_property(block.sprite_eyes,"position",Vector2.ZERO,block.parent_bokobody.movement_time*4.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)


func anim_hit_block(transformed_to) -> void:
	var dur: float = 0.9
	var anim_to: Vector2
	
	GameUtil.reset_tween(tween_turn)
	
	block.sprite_block.skew = deg_to_rad(0.0)
	block.sprite_eyes.texture = asset_eye_close
	block.sprite_node_2.modulate = Color(Color.WHITE)
	
	match typeof(transformed_to):
		
		Variant.Type.TYPE_FLOAT: # Turn
			anim_to = Vector2.ONE/1.75
			
			GameUtil.reset_tween(tween_move)
			GameUtil.reset_tween(tween_hit_block)
			
			tween_hit_block = create_tween()
			tween_hit_block.set_ease(Tween.EASE_OUT)
			tween_hit_block.tween_property(block.sprite_node_2,"scale",anim_to,dur/20.0)
			tween_hit_block.tween_property(block.sprite_node_2,"scale",Vector2.ONE,dur/1.1).set_trans(Tween.TRANS_ELASTIC)
			
		Variant.Type.TYPE_VECTOR2: # Move
			var high := 1.2
			var low := 0.8
			var squash : float
			var stretch : float

			if block.parent_bokobody:
				match block.parent_bokobody.get_current_turn():
					1, 3:
						squash = low
						stretch = high
					2, 4:
						squash = high
						stretch = low
			else:
				squash = low
				stretch = high
			
			match transformed_to:
				Vector2.UP, Vector2.DOWN:
					anim_to = Vector2(stretch,squash)
				Vector2.RIGHT, Vector2.LEFT:
					anim_to = Vector2(squash,stretch)
				_:
					anim_to = Vector2.ONE 
				
			GameUtil.reset_tween(tween_move)
			GameUtil.reset_tween(tween_hit_block)
			tween_hit_block = create_tween()
			tween_hit_block.set_ease(Tween.EASE_OUT)
			tween_hit_block.tween_property(block.sprite_node_2,"scale",anim_to,dur/10.0)
			tween_hit_block.tween_property(block.sprite_node_2,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
				
		_:
			pass

	await get_tree().create_timer(dur/2.6).timeout
	if block.is_on_starpoint:
		block.sprite_eyes.texture = asset_eye_happy
	else:
		block.sprite_eyes.texture = block.texture_eyes


func anim_entered_one_color_wall() -> void:
	if block.parent_bokobody:
		block.parent_bokobody.child_block_entered_one_col_wall.emit(block)
		
		
func anim_exited_one_color_wall() -> void:
	if block.parent_bokobody:
		block.parent_bokobody.child_block_exited_one_col_wall.emit()


func anim_complete() -> void:
	var first_anim_dur: float = 0.5
	var sec_anim_dur: float = 0.6
	var zoom_to: Vector2 = Vector2.ONE * 1.25
	var modulate_to: Color = Color.WHITE*2.0
	var rot_to: float = rad_to_deg(PI)
	
	block.limit_eye_movement = false
	block.sprite_node_2.modulate = Color(Color.WHITE*2.0)
	
	var tween := create_tween().set_parallel(true)
	
	# Oh dear, lord. Please just Alt+Z. 
	tween.tween_property(block.sprite_node_2,"scale",zoom_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(block.sprite_node_2,"modulate",modulate_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(block.sprite_node_2,"scale",Vector2.ZERO,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(block.sprite_node_2,"rotation_degrees",rot_to,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(anim_star).set_delay(first_anim_dur*2.0)


func anim_pulse() -> void:
	var dur: float = 0.6
	
	block.sprite_node_2.modulate = Color(Color.WHITE*2.4)
	
	GameUtil.reset_tween(tween_pulse)

	tween_pulse = create_tween()
	tween_pulse.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween_pulse.tween_property(block.sprite_node_2,"modulate",Color(Color.WHITE),dur)


func anim_ghost() -> void:
	var dur: float = 0.6
	var zoom_to: float = 0.75
	
	var sprite := block.sprite_ghost.duplicate() as Sprite2D
	sprite.scale = Vector2.ZERO
	sprite.position = block.sprite_ghost.global_position
	sprite.z_index = 4
	if GameMgr.current_stage:
		GameMgr.current_stage.add_child(sprite)
	
	if tween_ghosts:
		tween_ghosts.kill()
	
	tween_ghosts = create_tween().set_parallel(true)
	tween_ghosts.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_ghosts.tween_property(sprite,"scale",Vector2.ONE*zoom_to,dur)
	tween_ghosts.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.4),dur)
	tween_ghosts.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.0),dur*1.25).set_delay(dur)


func anim_star() -> void:
	var rand: float = randf()/3.0
	var dur: float = 0.4
	
	await get_tree().create_timer(rand).timeout
	
	if tween_ghosts:
		tween_ghosts.kill()
	
	tween_ghosts = create_tween().set_parallel(true)
	tween_ghosts.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_ghosts.tween_property(block.sprite_star,"scale",Vector2.ONE/2.0,dur)
	tween_ghosts.tween_property(block.sprite_star,"self_modulate",Color(Color.WHITE,0.5),dur)
	tween_ghosts.tween_property(block.sprite_star,"self_modulate",Color(Color.WHITE,0.0),dur*1.25).set_delay(dur)


func anim_entered_starpoint() -> void:
	var dur: float = 0.4
	
	block.sprite_eyes.texture = asset_eye_happy
	if tween_starpoint:
		tween_starpoint.kill()
	
	block.sprite_node_1.scale = Vector2.ZERO
	
	tween_starpoint = create_tween().set_parallel(true)
	tween_starpoint.set_ease(Tween.EASE_OUT)
	tween_starpoint.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
	tween_starpoint.tween_property(block.sprite_node_1,"modulate",Color(Color(1.25,1.25,1.25)),dur/2.0)
		

func anim_exited_starpoint() -> void:
	var dur: float = 1.0
	
	block.sprite_eyes.texture = block.texture_eyes
	block.sprite_node_1.scale = Vector2.ONE / 2.0
	
	if tween_starpoint:
		tween_starpoint.kill()
	tween_starpoint = create_tween().set_parallel(true)
	tween_starpoint.set_ease(Tween.EASE_OUT)
	tween_starpoint.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
	tween_starpoint.tween_property(block.sprite_node_1,"modulate",Color(Color.WHITE),dur/4.0)


func anim_landed_starpoint(has_landed: bool) -> void:
	if has_landed:
		anim_entered_starpoint()
	else:
		anim_exited_starpoint()


func anim_bokocolor_changed() -> void: ## @experimental
	var dur: float = 0.75
	
	block.sprite_eyes.texture = block.texture_eyes
	block.sprite_node_1.scale = Vector2.ONE / 1.385
	
	if tween_bokocolor:
		tween_bokocolor.kill()
	tween_bokocolor = create_tween().set_parallel(true)
	tween_bokocolor.set_ease(Tween.EASE_OUT)
	tween_bokocolor.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
	tween_bokocolor.tween_property(block.sprite_node_1,"modulate",Color(Color.WHITE),dur/4.0)


func anim_removed() -> void: ## @experimental
	if _is_being_removed:
		return
	
	_is_being_removed = true
	
	var dur: float = 0.3
	var rot_to: float = PI * signf(randf() - 0.5)
	
	block.sprite_eyes.texture = asset_eye_close
	block.modulate = Color(Color.WHITE/2)
	
	var tween := create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(block.sprite_node_1,"scale",Vector2.ZERO,dur)
	tween.tween_property(block.sprite_node_1,"rotation",rot_to,dur)
	
