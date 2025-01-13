## Use [url]res://object/objects/obj_block.tscn[\url].
extends Area2D
class_name Bokoblock

@export var boko_color: GameUtil.BokoColor
@export_group("Modify")
@export var auto_check_origin: bool = true
@export var make_origin: bool = false
@export_group("Assets")
@export var asset_block: Texture2D = preload("res://assets/objects/block-v06-greyscale.png")
@export var asset_origin_block: Texture2D = preload("res://assets/objects/block-v06-greyscale-origin.png")
@export var asset_eye_normal: Texture2D = preload("res://assets/objects/block-eyes-v03-neutral-white.png")
@export var asset_eye_angry: Texture2D = preload("res://assets/objects/block-eyes-v03-angry-white.png")
@export var asset_eye_scaredy: Texture2D = preload("res://assets/objects/block-eyes-v03-scaredy-white.png")
@export var asset_eye_close: Texture2D = preload("res://assets/objects/block-eye-close.png")
@export var asset_eye_happy: Texture2D = preload("res://assets/objects/block-eyes-v03-happy-white.png")

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var particles_dust: CPUParticles2D = $Dust
@onready var sprite_node_1: Node2D = $Sprites
@onready var sprite_node_2: Node2D = $Sprites/SpritesMove
@onready var sprite_eyes: Sprite2D = $Sprites/SpritesMove/Eyes
@onready var sprite_block: Sprite2D = $Sprites/SpritesMove/Block
@onready var sprite_star: Sprite2D = $Star
@onready var sprite_ghost: Sprite2D = $Ghost

var parent_bokobody: Bokobody
var is_on_starpoint: bool
var limit_eye_movement: bool = true
var texture_eyes: Texture2D

var _tween_pulse: Tween
var _tween_eyes: Tween
var _tween_move: Tween
var _tween_turn: Tween
var _tween_hit_block: Tween
var _tween_ghosts: Tween
var _tween_starpoint: Tween


func _ready() -> void:
	_setup_node()
	check_state()
	
	GameMgr.current_blocks.append(self)
	
	GameLogic.stage_won.connect(anim_complete)
	GameLogic.bokobodies_stopped.connect(check_state)
	
	if get_parent() is Bokobody:
		parent_bokobody = get_parent() as Bokobody
		
	else:
		push_warning("Recommended that %s must be a child of Bokobody." % str(self))
	
	if parent_bokobody:
		_setup_parent()
		
		parent_bokobody.child_blocks.append(self)
		
		parent_bokobody.has_moved.connect(func(moved_to: Vector2):
			particles_dust.direction = moved_to * -1
			
			anim_move(moved_to)
			)
		parent_bokobody.has_turned.connect(anim_turn)
		parent_bokobody.move_stopped.connect(stop_anim_move)
		
		body_entered.connect(func(body: Node2D):
			if (body is TileMapLayer || body is SleepingBlock):
				anim_hit_block(parent_bokobody.current_last_transform)
			)


func _process(_delta: float) -> void:
	if limit_eye_movement && sprite_eyes:
		sprite_eyes.global_rotation = 0.0
		sprite_eyes.position.x = clamp(sprite_eyes.position.x,-7.0,7.0)
		sprite_eyes.position.y = clamp(sprite_eyes.position.y,-7.0,7.0)
	
	if parent_bokobody:
		particles_dust.emitting = parent_bokobody.is_moving
		particles_dust.global_rotation = 0.0


func _setup_node() -> void:
	collision_layer = 1
	collision_mask = 7
	
	sprite_block.self_modulate = GameUtil.set_boko_color(boko_color)
	
	if auto_check_origin:
		_set_as_origin_block(self.position == Vector2.ZERO)
	else:
		_set_as_origin_block(make_origin)


func _setup_parent() -> void:
	if parent_bokobody:
		if parent_bokobody.turning_strength == abs(2):
			texture_eyes = asset_eye_scaredy
		
		elif parent_bokobody.turning_strength < 0:
			texture_eyes = asset_eye_angry
			
		else:
			texture_eyes = asset_eye_normal
		
		sprite_eyes.texture = texture_eyes


func check_state() -> void:
	var areas := get_overlapping_areas()
	#var bodies := get_overlapping_bodies()
	
	#var is_on_tile := areas.size() == 1
	#var is_on_object := bodies.size() == 1
	
	var has_stood_on_starpoint := areas.size() == 1 && areas[0] is Starpoint

	var is_on_happy_starpoint := false
	
	if has_stood_on_starpoint:
		is_on_happy_starpoint = (areas[0] as Starpoint).what_im_happy_with == boko_color
	
	if is_on_happy_starpoint && !is_on_starpoint:
		anim_entered_starpoint()
		is_on_starpoint = true
		
	elif !is_on_happy_starpoint && is_on_starpoint:
		anim_exited_starpoint()
		is_on_starpoint = false


func can_we_stop_moving_dad() -> bool:
	var yes: bool
	
	if parent_bokobody:
		parent_bokobody.stop_transforming()
		yes = true
	else:
		yes = false
		
	return yes


func anim_turn(turned_by: float, pulse: bool = true) -> void:
	var dur := 10.0
	var wobble_to: float = deg_to_rad(20.0) * sign(turned_by)
	
	if parent_bokobody:
		dur = parent_bokobody.movement_time * 8.0
	
	sprite_block.skew = wobble_to
	
	if pulse:
		anim_pulse()
	
	GameUtil.reset_tween(_tween_turn)
	_tween_turn = create_tween()
	_tween_turn.set_ease(Tween.EASE_OUT)
	_tween_turn.tween_property(sprite_block,"skew",0.0,dur).set_trans(Tween.TRANS_ELASTIC)
	
	
func anim_move(moved_to: Vector2, p_anim_eyes: bool = true) -> void:
	var anim_to: Vector2
	var dur := 0.5
	var high := 1.35
	var low := 0.65
	var squash : float
	var stretch : float
	
	if parent_bokobody:
		match parent_bokobody.get_current_turn():
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
	
	GameUtil.reset_tween(_tween_move)
	_tween_move = create_tween()
	_tween_move.set_ease(Tween.EASE_OUT)
	_tween_move.tween_property(sprite_node_2,"scale",anim_to,dur/6.0)
	_tween_move.tween_property(sprite_node_2,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)


func anim_eyes(moved_to: Vector2) -> void:
	if parent_bokobody == null:
		return

	var move_eyes_to := 7.0

	sprite_eyes.global_position += (moved_to as Vector2) * move_eyes_to
	
	GameUtil.reset_tween(_tween_eyes)
	_tween_eyes = create_tween()
	_tween_eyes.tween_property(sprite_eyes,"position",Vector2.ZERO,parent_bokobody.movement_time*4.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)


func anim_hit_block(transformed_to: Variant = Vector2.ZERO) -> void:
	var dur := 0.9
	var anim_to: Vector2
	
	GameUtil.reset_tween(_tween_turn)
	
	sprite_block.skew = deg_to_rad(0.0)
	sprite_eyes.texture = asset_eye_close
	sprite_node_2.modulate = Color(Color.WHITE)
	
	match typeof(transformed_to):
		
		Variant.Type.TYPE_FLOAT: # Turn
			anim_to = Vector2.ONE/3.0
			
			GameUtil.reset_tween(_tween_move)
			GameUtil.reset_tween(_tween_hit_block)
			
			_tween_hit_block = create_tween()
			_tween_hit_block.set_ease(Tween.EASE_OUT)
			_tween_hit_block.tween_property(sprite_node_2,"scale",anim_to,dur/20.0)
			_tween_hit_block.tween_property(sprite_node_2,"scale",Vector2.ONE,dur/1.1).set_trans(Tween.TRANS_ELASTIC)
			
		Variant.Type.TYPE_VECTOR2: # Move
			var high := 1.35
			var low := 0.65
			var squash : float
			var stretch : float

			if parent_bokobody:
				match parent_bokobody.get_current_turn():
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
				
			GameUtil.reset_tween(_tween_move)
			GameUtil.reset_tween(_tween_hit_block)
			_tween_hit_block = create_tween()
			_tween_hit_block.set_ease(Tween.EASE_OUT)
			_tween_hit_block.tween_property(sprite_node_2,"scale",anim_to,dur/10.0)
			_tween_hit_block.tween_property(sprite_node_2,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
				
		_:
			pass

	await get_tree().create_timer(dur/2.6).timeout
	if is_on_starpoint:
		sprite_eyes.texture = asset_eye_happy
	else:
		sprite_eyes.texture = texture_eyes


func anim_entered_one_color_wall() -> void:
	if parent_bokobody:
		parent_bokobody.child_block_entered_one_col_wall.emit(self)
		
		
func anim_exited_one_color_wall() -> void:
	if parent_bokobody:
		parent_bokobody.child_block_exited_one_col_wall.emit()


func anim_complete() -> void:
	var first_anim_dur := 0.5
	var sec_anim_dur := 0.6
	var zoom_to := Vector2.ONE * 1.25
	var modulate_to := Color.WHITE*2.0
	var rot_to := rad_to_deg(PI)
	
	limit_eye_movement = false
	sprite_node_2.modulate = Color(Color.WHITE*2.0)
	
	var tween := create_tween().set_parallel(true)
	
	# Oh dear, lord. Please just Alt+Z. 
	tween.tween_property(sprite_node_2,"scale",zoom_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite_node_2,"modulate",modulate_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite_node_2,"scale",Vector2.ZERO,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite_node_2,"rotation_degrees",rot_to,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(anim_star).set_delay(first_anim_dur*2.0)


func anim_pulse() -> void:
	var dur := 0.6
	
	sprite_node_2.modulate = Color(Color.WHITE*2.4)
	
	GameUtil.reset_tween(_tween_pulse)

	_tween_pulse = create_tween()
	_tween_pulse.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	_tween_pulse.tween_property(sprite_node_2,"modulate",Color(Color.WHITE),dur)


func anim_ghost() -> void:
	var dur := 0.6
	var zoom_to := 0.75
	
	var sprite := sprite_ghost.duplicate() as Sprite2D
	sprite.scale = Vector2.ZERO
	sprite.position = sprite_ghost.global_position
	sprite.z_index = 4
	if GameMgr.current_stage:
		GameMgr.current_stage.add_child(sprite)
	
	if _tween_ghosts:
		_tween_ghosts.kill()
	
	_tween_ghosts = create_tween().set_parallel(true)
	_tween_ghosts.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_ghosts.tween_property(sprite,"scale",Vector2.ONE*zoom_to,dur)
	_tween_ghosts.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.4),dur)
	_tween_ghosts.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.0),dur*1.25).set_delay(dur)


func anim_star() -> void:
	var rand := randf()/3.0
	var dur := 0.4
	
	await get_tree().create_timer(rand).timeout
	
	if _tween_ghosts:
		_tween_ghosts.kill()
	
	_tween_ghosts = create_tween().set_parallel(true)
	_tween_ghosts.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_ghosts.tween_property(sprite_star,"scale",Vector2.ONE/2.0,dur)
	_tween_ghosts.tween_property(sprite_star,"self_modulate",Color(Color.WHITE,0.5),dur)
	_tween_ghosts.tween_property(sprite_star,"self_modulate",Color(Color.WHITE,0.0),dur*1.25).set_delay(dur)


func anim_entered_starpoint() -> void:
	var dur := 0.4
	
	sprite_eyes.texture = asset_eye_happy
	if _tween_starpoint:
		_tween_starpoint.kill()
	
	sprite_node_1.scale = Vector2.ZERO
	
	_tween_starpoint = create_tween().set_parallel(true)
	_tween_starpoint.set_ease(Tween.EASE_OUT)
	_tween_starpoint.tween_property(sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
	_tween_starpoint.tween_property(sprite_node_1,"modulate",Color(Color(1.25,1.25,1.25)),dur/2.0)
		

func anim_exited_starpoint() -> void:
	var dur := 1.0
	
	sprite_eyes.texture = texture_eyes
	sprite_node_1.scale = Vector2.ONE / 4.0
	
	if _tween_starpoint:
		_tween_starpoint.kill()
	_tween_starpoint = create_tween().set_parallel(true)
	_tween_starpoint.set_ease(Tween.EASE_OUT)
	_tween_starpoint.tween_property(sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
	_tween_starpoint.tween_property(sprite_node_1,"modulate",Color(Color.WHITE),dur/4.0)


func stop_anim_move() -> void:
	GameUtil.reset_tween(_tween_move)
	
	sprite_node_2.scale = Vector2.ONE


func _set_as_origin_block(is_origin: bool) -> void:
	if is_origin:
		sprite_block.texture = asset_origin_block
		self.z_index = 1
	else:
		sprite_block.texture = asset_block
		self.z_index = 0
