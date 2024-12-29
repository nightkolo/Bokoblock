## Under construction
extends Area2D
class_name Bokoblock

## @deprecated: Use [enum GameLogic.BokoColor].
enum BokoColor {AQUA = 0, RED = 1, BLUE = 2, YELLOW = 3, GREEN = 4, PINK = 5}

@export var boko_color: GameLogic.BokoColor
@export_group("Modify")
@export var auto_check_origin: bool = true
@export var make_origin: bool = false
@export_group("Objects to Assign")
@export var sprite_node_1: Node2D
@export var sprite_node_2: Node2D
@export var sprite_eyes: Sprite2D
@export var sprite_block: Sprite2D
@export var sprite_star: Sprite2D
@export var sprite_ghost: Sprite2D
@export_subgroup("Assets")
@export var asset_block: Texture2D = preload("res://assets/img/block-v06-greyscale.png")
@export var asset_origin_block: Texture2D = preload("res://assets/img/block-v06-greyscale.png")
@export var asset_eye_normal: Texture2D = preload("res://assets/img/block-eyes-v03-neutral-white.png")
@export var asset_eye_angry: Texture2D = preload("res://assets/img/block-eyes-v03-angry-white.png")
@export var asset_eye_scaredy: Texture2D = preload("res://assets/img/block-eyes-v03-scaredy-white.png")
@export var asset_eye_close: Texture2D = preload("res://assets/img/block-eye-close.png")

var parent_bokobody: Bokobody
var is_on_endpoint: bool = false
var limit_eye_movement: bool = true
var texture_eyes: Texture2D
var we_can_pass_one_color_block: bool = false

var _current_transformation: Variant
var _tween_eyes: Tween
var _tween_move: Tween
var _tween_turn: Tween
var _tween_hit_block: Tween
var _tween_complete: Tween
var _tween_ghosts: Tween
var _tween_endpoint: Tween


func anim_entered_one_color_block() -> void:
	if parent_bokobody:
		parent_bokobody.child_block_has_entered_one_way_block.emit(self)
		
		
func anim_exited_one_color_block() -> void:
	if parent_bokobody:
		parent_bokobody.child_blocks_left_one_way_block.emit()


func _ready() -> void:
	_setup_node()
	_setup_sprite()
	check_state()
	
	if get_parent() is Bokobody:
		parent_bokobody = (get_parent() as Bokobody)
		
	else:
		push_warning("Recommended that " + str(self) + " must be a child of Bokobody.")
	
	if parent_bokobody:
		parent_bokobody.moved.connect(anim_move)
		parent_bokobody.move_stopped.connect(stop_anim_move)
		parent_bokobody.turned.connect(anim_turn)
		
		#if parent_bokobody.rotation_strength == abs(2):
		texture_eyes = asset_eye_scaredy
		
		#elif parent_bokobody.rotation_strength < 0:
			#texture_eyes = asset_eye_angry
			#
		#else:
			#texture_eyes = asset_eye_normal
		
		sprite_eyes.texture = texture_eyes
		
		body_entered.connect(func(body: Node2D):
			if (body is TileMapLayer || body is SleepingBlock):
				anim_hit_block()
			)
	
	GameLogic.game_end.connect(anim_complete)
	GameLogic.bokobodies_stopped.connect(check_state)
	GameLogic.bokobodies_moved.connect(anim_eyes)


func check_state() -> void:
	var areas := get_overlapping_areas()
	var has_stood_on_endpoint := areas.size() == 1 && areas[0] is Endpoint
	var is_on_happy_endpoint: bool = false
	
	if has_stood_on_endpoint:
		is_on_happy_endpoint = (areas[0] as Endpoint).what_im_happy_with == boko_color
	
	if is_on_happy_endpoint && !is_on_endpoint:
		anim_standing_endpoint()
		is_on_endpoint = true
		
	elif !is_on_happy_endpoint && is_on_endpoint:
		anim_left_endpoint()
		is_on_endpoint = false


func _setup_node() -> void:
	collision_layer = 1
	collision_mask = 7
	
	if !_are_nodes_assgined():
		return
		
	if auto_check_origin:
		_set_as_origin_block(self.position == Vector2.ZERO)
	else:
		_set_as_origin_block(make_origin)


func _setup_sprite() -> void:
	if !_are_nodes_assgined():
		return 
		
	sprite_block.offset.y = -45.0
	sprite_block.position.y = 22.5
	
	sprite_block.self_modulate = GameLogic.set_boko_color(boko_color)


func _process(_delta: float) -> void:
	if limit_eye_movement && sprite_eyes:
		sprite_eyes.global_rotation = 0.0
		sprite_eyes.position.x = clamp(sprite_eyes.position.x,-7.0,7.0)
		sprite_eyes.position.y = clamp(sprite_eyes.position.y,-7.0,7.0)


func anim_turn(turned_by: float) -> void:
	if !_are_nodes_assgined():
		return
	
	var dur := 10.0
	var wobble_to: float = deg_to_rad(20.0) * sign(turned_by)
	
	if parent_bokobody:
		dur = parent_bokobody.movement_time * 8.0
	
	_current_transformation = turned_by
	
	sprite_block.skew = wobble_to
	
	if _tween_turn:
		_tween_turn.kill()
	_tween_turn = create_tween()
	_tween_turn.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_turn.tween_property(sprite_block,"skew",0.0,dur)
	
	
func anim_move(moved_to: Vector2) -> void:
	if !_are_nodes_assgined():
		return
	
	var anim_to: Vector2
	var squash := 0.65
	var stretch := 1.35
	var dur := 0.5
	
	if parent_bokobody:
		dur = parent_bokobody.movement_time * 5.0
	
	_current_transformation = moved_to
	
	match moved_to:
		Vector2.RIGHT:
			anim_to = Vector2(stretch,squash)
		Vector2.LEFT:
			anim_to = Vector2(stretch,squash)
		Vector2.UP:
			anim_to = Vector2(squash,stretch)
		Vector2.DOWN:
			anim_to = Vector2(squash,stretch)
		_:
			anim_to = Vector2.ONE
	
	if _tween_move:
		_tween_move.kill()
	_tween_move = create_tween()
	_tween_move.set_ease(Tween.EASE_OUT)
	_tween_move.tween_property(sprite_node_2,"scale",anim_to,dur/6.0)
	_tween_move.tween_property(sprite_node_2,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)


func anim_eyes(transformed_to: Variant) -> void:
	if !_are_nodes_assgined() || parent_bokobody == null:
		return

	var move_eyes_to := 7.0
	
	match typeof(transformed_to):
		
		Variant.Type.TYPE_VECTOR2:
			sprite_eyes.global_position += (transformed_to as Vector2) * move_eyes_to
			if _tween_eyes:
				_tween_eyes.kill()
			_tween_eyes = create_tween()
			_tween_eyes.tween_property(sprite_eyes,"position",Vector2.ZERO,parent_bokobody.movement_time*4.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)


func anim_hit_block(transformed_to: Variant = _current_transformation) -> void:
	if !_are_nodes_assgined():
		return
	
	var dur := 0.9
	var anim_to: Vector2
	
	sprite_eyes.texture = asset_eye_close
	
	match typeof(transformed_to):
		
		Variant.Type.TYPE_FLOAT: # Turn
			anim_to = Vector2.ONE/3.0
			
			if _tween_move:
				_tween_move.kill()
			if _tween_hit_block:
				_tween_hit_block.kill()
			
			_tween_hit_block = create_tween()
			_tween_hit_block.set_ease(Tween.EASE_OUT)
			_tween_hit_block.tween_property(sprite_node_2,"scale",anim_to,dur/20.0)
			_tween_hit_block.tween_property(sprite_node_2,"scale",Vector2.ONE,dur/1.1).set_trans(Tween.TRANS_ELASTIC)
			
		Variant.Type.TYPE_VECTOR2: # Move
			var squash := 0.65
			var stretch := 1.35
			
			match transformed_to:
				Vector2.UP:
					anim_to = Vector2(stretch,squash)
				Vector2.DOWN:
					anim_to = Vector2(stretch,squash)
				Vector2.RIGHT:
					anim_to = Vector2(squash,stretch)
				Vector2.LEFT:
					anim_to = Vector2(squash,stretch)
				_:
					anim_to = Vector2.ONE 
				
			if _tween_move:
				_tween_move.kill()
			if _tween_hit_block:
				_tween_hit_block.kill()
			
			_tween_hit_block = create_tween()
			_tween_hit_block.set_ease(Tween.EASE_OUT)
			_tween_hit_block.tween_property(sprite_node_2,"scale",anim_to,dur/10.0)
			_tween_hit_block.tween_property(sprite_node_2,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
				
		_:
			pass

	await get_tree().create_timer(dur/2.6).timeout
	sprite_eyes.texture = texture_eyes

func anim_complete() -> void:
	if !_are_nodes_assgined():
		return
	
	var first_anim_dur := 0.5
	var sec_anim_dur := 0.6
	var zoom_to := Vector2.ONE * 1.25
	var modulate_to := Color(2.0,2.0,2.0)
	var rot_to := rad_to_deg(PI)
	
	limit_eye_movement = false
	sprite_node_2.modulate = Color(Color(2.0,2.0,2.0))
	
	_tween_complete = create_tween().set_parallel(true)
	
	# Oh dear, lord. Please just Alt+Z. 
	_tween_complete.tween_property(sprite_node_2,"scale",zoom_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_complete.tween_property(sprite_node_2,"modulate",modulate_to,first_anim_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_complete.tween_property(sprite_node_2,"scale",Vector2.ZERO,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_tween_complete.tween_property(sprite_node_2,"rotation_degrees",rot_to,sec_anim_dur).set_delay(first_anim_dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_tween_complete.tween_callback(anim_star).set_delay(first_anim_dur*2.0)


func anim_ghost() -> void:
	if !_are_nodes_assgined():
		pass

	var dur := 0.6
	var zoom_to := 0.75
	
	var sprite := sprite_ghost.duplicate() as Sprite2D
	sprite.scale = Vector2.ZERO
	sprite.position = sprite_ghost.global_position
	sprite.z_index = 4
	if GameLogic.current_level:
		GameLogic.current_level.add_child(sprite)
	
	if _tween_ghosts:
		_tween_ghosts.kill()
	
	_tween_ghosts = create_tween().set_parallel(true)
	_tween_ghosts.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_ghosts.tween_property(sprite,"scale",Vector2.ONE*zoom_to,dur)
	_tween_ghosts.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.4),dur)
	_tween_ghosts.tween_property(sprite,"self_modulate",Color(Color.WHITE,0.0),dur*1.25).set_delay(dur)


func anim_star() -> void:
	if !_are_nodes_assgined():
		pass

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


func anim_standing_endpoint() -> void:
	if _are_nodes_assgined():
		var dur := 0.4
		
		sprite_eyes.texture = preload("res://assets/img/block-eyes-v03-happy-white.png")
		if _tween_endpoint:
			_tween_endpoint.kill()
		
		sprite_node_1.scale = Vector2.ONE/2.0
		
		_tween_endpoint = create_tween().set_parallel(true)
		_tween_endpoint.set_ease(Tween.EASE_OUT)
		_tween_endpoint.tween_property(sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
		_tween_endpoint.tween_property(sprite_node_1,"modulate",Color(Color(1.25,1.25,1.25)),dur/2.0)
		

func anim_left_endpoint() -> void:
	if _are_nodes_assgined():
		var dur := 0.8
		
		sprite_eyes.texture = texture_eyes
		sprite_node_1.scale = Vector2.ONE / 2.0
		
		if _tween_endpoint:
			_tween_endpoint.kill()
		_tween_endpoint = create_tween().set_parallel(true)
		_tween_endpoint.set_ease(Tween.EASE_OUT)
		_tween_endpoint.tween_property(sprite_node_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
		_tween_endpoint.tween_property(sprite_node_1,"modulate",Color(Color.WHITE),dur/4.0)


func stop_anim_move() -> void:
	if _tween_move:
		_tween_move.kill()
	
	sprite_node_2.scale = Vector2.ONE


func call_dad_to_pass_color_block() -> void:
	if parent_bokobody:
		parent_bokobody.we_shall_pass_the_one_color_block = true


func can_we_stop_moving_dad() -> bool:
	var yes: bool
	
	if parent_bokobody:
		parent_bokobody.stop_making_move()
		yes = true
	else:
		yes = false
		
	return yes


func _are_nodes_assgined() -> bool:
	return sprite_node_1 != null && sprite_node_2 != null && sprite_block != null && sprite_eyes != null && sprite_star != null
	

func _set_as_origin_block(is_origin: bool) -> void:
	if is_origin:
		sprite_block.texture = asset_origin_block
		self.z_index = 1
	else:
		sprite_block.texture = asset_block
		self.z_index = 0


func _rad_to_vector(rad: float) -> Vector2:
	var x = cos(rad)
	var y = sin(rad)
	return Vector2(x, y)
