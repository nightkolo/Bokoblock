extends Node
class_name BokoblockAnimationComponent

@export_category("Assets")
@export var asset_eye_close: Texture2D = preload("res://assets/objects/block-eye-close.png")
@export var asset_eye_happy: Texture2D = preload("res://assets/objects/block-eyes-happy.png")
@export var asset_eye_dizzy: Texture2D = preload("res://assets/objects/block-eyes-dizzy.png")
@export var asset_eye_on_button: Texture2D = preload("res://assets/objects/block-eyes-on-button.png")

@onready var block: Bokoblock = get_parent() as Bokoblock

var timer_poke: Timer = Timer.new()
#var timer_look_at_me: Timer = Timer.new() ## @deprecated

func _ready() -> void:
	if !(block is Bokoblock):
		push_error("%s is not a child of Bokoblock." % str(self))
		return
	
	timer_poke.wait_time = 0.3
	add_child(timer_poke)
	
	#timer_look_at_me.wait_time = 1.0
	#timer_look_at_me.one_shot = false
	#add_child(timer_look_at_me)
	#timer_look_at_me.start()
	
	GameLogic.stage_won.connect(anim_stage_won)
	
	block.starpoint_entered.connect(anim_landed_starpoint)
	block.blackpoint_entered.connect(anim_landed_blackpoint)
	#block.button_entered.connect(anim_landed_on_button)
	
	#block.body_entered.connect(func(body: Node2D):
		#if (body is TileMapLayer || body is SleepingBlock):
			#anim_hit_wall(block.parent_bokobody.get_current_last_transform())
		#)
		
	await GameMgr.process_waittime()
	if block.parent_bokobody:
		block.parent_bokobody.has_moved.connect(func(moved_to: Vector2):
			block.particles_dust.direction = moved_to * -1
			
			anim_move(moved_to)
			)
		block.parent_bokobody.has_turned.connect(anim_turn)

		block.parent_bokobody.move_stopped.connect(func():
			stop_anim_move()
			
			var last_trans := block.parent_bokobody.get_current_last_transform() as Vector2
			
			if block.wall_detect(last_trans):
				anim_hit_wall(last_trans)
			)
		block.parent_bokobody.turn_stopped.connect(func():
			#await get_tree().create_timer(0.1).timeout
			anim_hit_wall(block.parent_bokobody.get_current_last_transform())
			)


var tween_turn: Tween ## @experimental

func anim_turn(_turned_by: float) -> void: ## @experimental
	#var dur: float
	#var wobble_to: float = deg_to_rad(20.0) * signf(turned_by)
	
	#if block.parent_bokobody:
		#dur = block.parent_bokobody.movement_time * 8.0
	
	#block.sprite_block.skew = wobble_to
	
	anim_turn_pulse()
	
	#GameUtil.reset_tween(tween_turn)
	#tween_turn = create_tween()
	#tween_turn.set_ease(Tween.EASE_OUT)
	#tween_turn.tween_property(block.sprite_block,"skew",0.0,dur).set_trans(Tween.TRANS_ELASTIC)


var tween_move: Tween
	
func anim_move(moved_to: Vector2, p_anim_eyes: bool = true) -> void:
	var anim_to: Vector2
	var dur: float = 0.6
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
	

var tween_hit_block: Tween

func anim_hit_wall(transformed_to) -> void:
	var dur: float = 1.0
	var anim_to: Vector2
	
	GameUtil.reset_tween(tween_turn)
	
	block.sprite_block.skew = deg_to_rad(0.0)
	block.sprite_eyes.texture = asset_eye_close
	block.sprite_node_2.modulate = Color(Color.WHITE)
	
	match typeof(transformed_to):
		
		Variant.Type.TYPE_FLOAT: # Turn
			anim_to = Vector2.ONE/1.45
			
			GameUtil.reset_tween(tween_move)
			GameUtil.reset_tween(tween_hit_block)
			
			tween_hit_block = create_tween()
			tween_hit_block.set_ease(Tween.EASE_OUT)
			tween_hit_block.tween_property(block.sprite_node_2,"scale",anim_to,dur/20.0)
			tween_hit_block.tween_property(block.sprite_node_2,"scale",Vector2.ONE,dur/1.1).set_trans(Tween.TRANS_ELASTIC)
			
		Variant.Type.TYPE_VECTOR2: # Move
			var high := 1.15
			var low := 0.85
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
	elif block.is_on_blackpoint:
		block.sprite_eyes.texture = asset_eye_dizzy
	else:
		block.sprite_eyes.texture = block.texture_eyes


var tween_eyes: Tween

func anim_eyes(moved_to: Vector2) -> void:
	if block.parent_bokobody == null:
		return

	var move_eyes_to := 6.0

	block.sprite_eyes.global_position += (moved_to as Vector2) * move_eyes_to
	
	GameUtil.reset_tween(tween_eyes)
	tween_eyes = create_tween()
	tween_eyes.tween_property(block.sprite_eyes,"position",Vector2.ZERO,block.parent_bokobody.movement_time*10.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)


var tween_pulse: Tween

func anim_turn_pulse() -> void:
	var dur: float = 0.75
	
	block.sprite_node_2.modulate = Color(Color.WHITE*5.0)
	
	GameUtil.reset_tween(tween_pulse)

	tween_pulse = create_tween()
	tween_pulse.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween_pulse.tween_property(block.sprite_node_2,"modulate",Color(Color.WHITE),dur)
	

var tween_poke: Tween

func anim_poke() -> void:
	if timer_poke.time_left > 0.0:
		timer_poke.stop()
	timer_poke.start()
	
	if tween_poke:
		tween_poke.kill()
	
	anim_rainbow()
	block.sprite_eyes.texture = asset_eye_close
	
	tween_poke = create_tween().set_parallel(true)
	tween_poke.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	var dur_bounce := 1.0 * 0.8
	var dur_delay := dur_bounce / 15.55
	var up: Vector2
	var down: Vector2
	var rot_to := signf(randf()-0.5) * (5.0 + (randf() * 4.0))
	var skew_to := signf(randf()-0.5) * (5.0 + (randf() * 4.0))
	
	_poked = !_poked

	if _poked:
		up = 0.5 * (Vector2.ONE / 1.3)
		down = 0.5 * (Vector2.ONE * 1.3)
	else:
		down = 0.5 * (Vector2.ONE / 3.5)
		up = 0.5 * (Vector2.ONE * 1.3)
	
	block.sprite_block.scale = up
	block.sprite_block.rotation_degrees = rot_to
	block.sprite_block.skew = deg_to_rad(skew_to)
	block.sprite_eyes.scale = down
	
	tween_poke.tween_property(block.sprite_block,"scale:x",0.5 * 1.0,dur_bounce)
	tween_poke.tween_property(block.sprite_eyes,"scale",0.5 * Vector2.ONE,dur_bounce)
	tween_poke.tween_property(block.sprite_block,"rotation_degrees",0.0,dur_bounce)
	tween_poke.tween_property(block.sprite_block,"skew",0.0,dur_bounce)
	tween_poke.tween_property(block.sprite_block,"scale:y",0.5 * 1.0,dur_bounce).set_delay(dur_delay)
	
	await timer_poke.timeout
	if block.is_on_starpoint:
		block.sprite_eyes.texture = asset_eye_happy
	elif block.is_on_blackpoint:
		block.sprite_eyes.texture = asset_eye_dizzy
	else:
		block.sprite_eyes.texture = block.texture_eyes


var tween_hue: Tween
var _poked: bool = false

func anim_rainbow() -> void:
	if tween_hue:
		tween_hue.kill()
	
	var dur := 0.5
	var strength := 0.55
	
	tween_hue = create_tween().set_parallel(true)
	
	block.sprite_node_block.modulate.h = 0.0
	tween_hue.tween_property(block.sprite_node_block,"modulate:h",1.0,dur)
	tween_hue.tween_property(block.sprite_node_block,"modulate:s",1.0 * strength,dur/4.0)
	tween_hue.tween_property(block.sprite_node_block,"modulate:s",0.0,dur/2.0).set_delay(dur/1.5)


func anim_stage_won() -> void:
	var first_anim_dur: float = 0.5
	var sec_anim_dur: float = 0.6
	var zoom_to: Vector2 = Vector2.ONE * 1.25
	var modulate_to: Color = Color.WHITE*2.0
	var rot_to: float = rad_to_deg(PI)
	
	block.sprite_node_2.modulate = Color(Color.WHITE*2.0)
	
	var tween := create_tween().set_parallel(true)
	
	# Oh dear, lord. Please just Alt+Z. 
	tween.tween_property(block.sprite_node_2,"scale",zoom_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(block.sprite_node_2,"modulate",modulate_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(block.sprite_node_2,"scale",Vector2.ZERO,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(block.sprite_node_2,"rotation_degrees",rot_to,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(anim_stage_won_star).set_delay(first_anim_dur*2.0)


func anim_stage_won_star() -> void:
	var rand: float = randf()/3.0
	var dur: float = 0.4
	
	await get_tree().create_timer(rand).timeout
	
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(block.sprite_star,"scale",Vector2.ONE/2.0,dur)
	tween.tween_property(block.sprite_star,"self_modulate",Color(Color.WHITE,0.5),dur)
	tween.tween_property(block.sprite_star,"self_modulate",Color(Color.WHITE,0.0),dur*1.25).set_delay(dur)


## Used by [method BokobodyAnimationComponent.anim_blocks_entered_one_col_wall)
func anim_ghost() -> void:
	var dur: float = 0.6
	var zoom_to: float = 0.75
	
	var sprite := block.sprite_ghost.duplicate() as Sprite2D
	sprite.scale = Vector2.ZERO
	sprite.position = block.sprite_ghost.global_position
	sprite.z_index = 4
	
	if GameMgr.current_board:
		GameMgr.current_board.add_child(sprite)
	
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite,"scale",Vector2.ONE*zoom_to,dur)
	tween.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.4),dur)
	tween.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.0),dur*1.25).set_delay(dur)
	await get_tree().create_timer(dur*2).timeout
	sprite.queue_free()


var tween_starpoint: Tween

func anim_entered_starpoint() -> void:
	var dur: float = 0.4
	
	block.sprite_eyes.texture = asset_eye_happy
	if tween_starpoint:
		tween_starpoint.kill()
	
	block.sprite_node_1.scale = Vector2.ONE / 2.0
	
	tween_starpoint = create_tween().set_parallel(true)
	tween_starpoint.set_ease(Tween.EASE_OUT)
	tween_starpoint.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
	tween_starpoint.tween_property(block.sprite_node_1,"modulate",Color(Color.WHITE*1.25),dur/2.0)
		

func anim_exited_starpoint() -> void:
	var dur: float = 0.5
	
	block.sprite_eyes.texture = block.texture_eyes
	block.sprite_node_1.scale = Vector2.ONE / 4.0
	
	if tween_starpoint:
		tween_starpoint.kill()
	tween_starpoint = create_tween().set_parallel(true)
	tween_starpoint.set_ease(Tween.EASE_OUT)
	tween_starpoint.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
	tween_starpoint.tween_property(block.sprite_node_1,"modulate",Color(Color.WHITE),dur/6.0)


var tween_blackpoint: Tween

func anim_entered_blackpoint() -> void:
	var dur: float = 0.4
	
	block.sprite_eyes.texture = asset_eye_dizzy
	
	if tween_blackpoint:
		tween_blackpoint.kill()
	
	block.sprite_node_1.scale = Vector2.ONE / 2.0
	
	tween_blackpoint = create_tween().set_parallel(true)
	tween_blackpoint.set_ease(Tween.EASE_OUT)
	tween_blackpoint.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
	tween_blackpoint.tween_property(block.sprite_node_1,"modulate",Color(Color.WHITE*0.6, 1.0),dur/2.0)
		

func anim_exited_blackpoint() -> void:
	var dur: float = 0.5
	
	if block.is_on_starpoint:
		block.sprite_eyes.texture = asset_eye_happy
	else:
		block.sprite_eyes.texture = block.texture_eyes
	block.sprite_node_1.scale = Vector2.ONE / 4.0
	
	if tween_blackpoint:
		tween_blackpoint.kill()
	tween_blackpoint = create_tween().set_parallel(true)
	tween_blackpoint.set_ease(Tween.EASE_OUT)
	tween_blackpoint.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
	tween_blackpoint.tween_property(block.sprite_node_1,"modulate",Color(Color.WHITE, 1.0),dur/6.0)


func anim_landed_blackpoint(has_landed: bool) -> void:
	if has_landed:
		anim_entered_blackpoint()
	else:
		anim_exited_blackpoint()
		

func anim_landed_starpoint(has_landed: bool) -> void:
	if has_landed:
		anim_entered_starpoint()
	else:
		anim_exited_starpoint()

	
func anim_entered_one_color_wall() -> void: ## @deprecated: Used by [OneColorWalls1]
	if block.parent_bokobody:
		block.parent_bokobody.child_block_entered_one_col_wall.emit(block)
		
		
func anim_exited_one_color_wall() -> void: ## @deprecated: Used by [OneColorWalls1]
	if block.parent_bokobody:
		block.parent_bokobody.child_block_exited_one_col_wall.emit()
