## Under construction
##
## Preferably use [url]res://object/objects/obj_block.tscn[\url].
extends Area2D
class_name Bokoblock

signal starpoint_entered(has_entered: bool)
signal blackpoint_entered(has_entered: bool)
signal blackpoint_interacted()

@export var boko_color: GameUtil.BokoColor
@export var colorblind_label: GameUtil.ColorblindLabel
@export_group("Modify")
@export var animator: BokoblockAnimationComponent
@export var auto_check_center: bool = true
@export var set_as_center: bool = false
@export_group("Assets")
@export var asset_block: Texture2D = preload("res://assets/objects/block-greyscale.png")
@export var asset_block_center: Texture2D = preload("res://assets/objects/block-greyscale-center.png")
@export var asset_eye_normal: Texture2D = preload("res://assets/objects/block-eyes-neutral.png")
@export var asset_eye_angry: Texture2D = preload("res://assets/objects/block-eyes-angry.png")
@export var asset_eye_scaredy: Texture2D = preload("res://assets/objects/block-eyes-scaredy.png")
@export_subgroup("Assets Colorblind mode")
@export var asset_cb_block: Texture2D = preload("res://assets/objects/block-colorblind-01.png")
@export var asset_cb_block_center: Texture2D = preload("res://assets/objects/block-colorblind-01-center.png")

@onready var ray_cast: RayCast2D = %RayCast2D
@onready var sprite_block: Sprite2D = %Block
@onready var sprite_eyes: Sprite2D = %Eyes
@onready var particles_dust: CPUParticles2D = $Dust

# Used by BokoblockAnimationComponent
@onready var sprite_node_1: Node2D = $Sprites
@onready var sprite_node_2: Node2D = %SpritesMove
@onready var sprite_node_block: Node2D = %SpriteBlock
@onready var sprite_star: Sprite2D = %Star
@onready var sprite_ghost: Sprite2D = %Ghost

var parent_bokobody: Bokobody
var is_on_starpoint: bool
var is_on_blackpoint: bool
var texture_eyes: Texture2D


func _ready() -> void:
	_setup_node()
	check_state()
	
	GameMgr.colorblind_mode_setting_set.connect(func(_is_on: bool):
		_setup_block_texture()
		)
		
	GameMgr.game_pause_toggled.connect(func(is_paused: bool):
		if !is_paused:
			_setup_block_texture()
		)
	
	GameLogic.current_blocks.append(self)
	GameLogic.bodies_stopped.connect(check_state)

	if get_parent() is Bokobody:
		parent_bokobody = get_parent() as Bokobody
		
	else:
		push_warning("Recommended that %s must be a child of Bokobody." % str(self))
	
	if parent_bokobody:
		_setup_parent()
		
		parent_bokobody.child_blocks.append(self)
		
		parent_bokobody.returned_from_blackpoint.connect(func():
			await get_tree().create_timer(0.1).timeout
			check_state(false)
			)


func _process(_delta: float) -> void:
	if sprite_eyes:
		sprite_eyes.global_rotation = 0.0
		sprite_eyes.position.x = clamp(sprite_eyes.position.x,-7.0,7.0)
		sprite_eyes.position.y = clamp(sprite_eyes.position.y,-5.0,5.0)
	
	if parent_bokobody:
		particles_dust.emitting = parent_bokobody.is_moving
		particles_dust.global_rotation = 0.0


func _setup_node() -> void:
	collision_layer = 1
	collision_mask = 7
	
	_setup_block_texture()


func _setup_block_texture() -> void:
	if auto_check_center:
		set_block_texture(self.position == Vector2.ZERO)
	else:
		set_block_texture(set_as_center)


func _setup_parent() -> void:
	if parent_bokobody:
		if parent_bokobody.turning_strength == absi(2):
			texture_eyes = asset_eye_scaredy
		
		elif parent_bokobody.turning_strength < 0:
			texture_eyes = asset_eye_angry
			
		else:
			texture_eyes = asset_eye_normal
		
		sprite_eyes.texture = texture_eyes


func check_state(emit_blackpoint_interacted_signal: bool = true) -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	var l_starpoint: bool = false
	var l_blackpoint: bool = false

	if areas.size() == 1:
		if areas[0] is Starpoint:
			l_starpoint = (areas[0] as Starpoint).what_im_happy_with == boko_color
		
		l_blackpoint = areas[0] is Blackpoint

	if l_starpoint && !is_on_starpoint:
		starpoint_entered.emit(l_starpoint)
		is_on_starpoint = true
	elif !l_starpoint && is_on_starpoint:
		starpoint_entered.emit(l_starpoint)
		is_on_starpoint = false
	
	if l_blackpoint && !is_on_blackpoint:
		blackpoint_entered.emit(l_blackpoint)
		is_on_blackpoint = true
	elif !l_blackpoint && is_on_blackpoint:
		blackpoint_entered.emit(l_blackpoint)
		is_on_blackpoint = false
	
	if l_blackpoint && emit_blackpoint_interacted_signal:
		blackpoint_interacted.emit()


func can_we_stop_moving_dad() -> bool:
	var yes: bool
	
	if parent_bokobody:
		parent_bokobody.stop_transforming()
		yes = true
	else:
		yes = false
		
	return yes


func wall_detect(direction: Vector2) -> bool:
	ray_cast.global_rotation = 0.0
	ray_cast.target_position = direction.sign() * GameUtil.TILE_SIZE
	
	ray_cast.force_raycast_update()
	return ray_cast.is_colliding()


func set_block_texture(is_center_block: bool = false) -> void:
	sprite_block.self_modulate = GameUtil.set_boko_color(boko_color)
	
	if GameMgr.get_colorblind_mode_setting():
		sprite_eyes.self_modulate = Color(Color.BLACK, 1.0)
		
		if is_center_block:
			sprite_block.texture = asset_cb_block
			self.z_index = 1
		else:
			sprite_block.texture = asset_cb_block_center
			self.z_index = 0
		
	else:
		sprite_eyes.self_modulate = Color(Color.WHITE, 0.8)
		
		if is_center_block:
			sprite_block.texture = asset_block_center
			self.z_index = 1
		else:
			sprite_block.texture = asset_block
			self.z_index = 0
