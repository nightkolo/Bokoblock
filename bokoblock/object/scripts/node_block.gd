## Under construction
##
## Preferably use [url]res://object/objects/obj_block.tscn[\url].
extends Area2D
class_name Bokoblock

signal starpoint_entered(has_entered: bool)
signal button_entered(has_entered: bool) ## @experimental

@export var boko_color: GameUtil.BokoColor
@export_group("Modify")
@export var animator: BokoblockAnimationComponent
@export var auto_check_center: bool = true
@export var set_as_center: bool = false
@export_category("Assets")
@export var asset_block: Texture2D = preload("res://assets/objects/block-greyscale.png")
@export var asset_center_block: Texture2D = preload("res://assets/objects/block-greyscale-center.png")
@export var asset_eye_normal: Texture2D = preload("res://assets/objects/block-eyes-neutral.png")
@export var asset_eye_angry: Texture2D = preload("res://assets/objects/block-eyes-angry.png")
@export var asset_eye_scaredy: Texture2D = preload("res://assets/objects/block-eyes-scaredy.png")

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
var is_on_button: bool ## @experimental: possibly deprecated?
var limit_eye_movement: bool = true ## @deprecated
var texture_eyes: Texture2D


func _ready() -> void:
	_setup_node()
	check_state()
	
	GameLogic.current_blocks.append(self)
	GameLogic.bodies_stopped.connect(check_state)
	
	if get_parent() is Bokobody:
		parent_bokobody = get_parent() as Bokobody
		
	else:
		push_warning("Recommended that %s must be a child of Bokobody." % str(self))
	
	if parent_bokobody:
		_setup_parent()
		
		parent_bokobody.child_blocks.append(self)


func _process(_delta: float) -> void:
	if limit_eye_movement && sprite_eyes:
		sprite_eyes.global_rotation = 0.0
		sprite_eyes.position.x = clamp(sprite_eyes.position.x,-7.0,7.0)
		sprite_eyes.position.y = clamp(sprite_eyes.position.y,-5.0,5.0)
	
	if parent_bokobody:
		particles_dust.emitting = parent_bokobody.is_moving
		particles_dust.global_rotation = 0.0


func _setup_node() -> void:
	collision_layer = 1
	collision_mask = 7
	
	sprite_block.self_modulate = GameUtil.set_boko_color(boko_color)
	
	if auto_check_center:
		_set_as_center_block(self.position == Vector2.ZERO)
	else:
		_set_as_center_block(set_as_center)


func _setup_parent() -> void:
	if parent_bokobody:
		if parent_bokobody.turning_strength == absi(2):
			texture_eyes = asset_eye_scaredy
		
		elif parent_bokobody.turning_strength < 0:
			texture_eyes = asset_eye_angry
			
		else:
			texture_eyes = asset_eye_normal
		
		sprite_eyes.texture = texture_eyes


func check_state() -> void:
	# TODO: Remove boilerplate code,
	# this function was refactored to make Bokoblocks work for the Debug Cards test area,
	# which isn't needed anymore. 
	
	var areas: Array[Area2D]
	var l_starpoint: bool = false
	var l_button: bool = false # possibly deprecated
	
	if (monitoring && monitorable): 
		areas = get_overlapping_areas()
		
	#var bodies := get_overlapping_bodies()

	#var is_on_tile := areas.size() == 1
	#var is_on_object := bodies.size() == 1
	
	if areas.size() == 1:
		if areas[0] is Starpoint:
			l_starpoint = (areas[0] as Starpoint).what_im_happy_with == boko_color
		
		l_button = areas[0] is ButtonObj
	
	if l_starpoint && !is_on_starpoint:
		starpoint_entered.emit(l_starpoint)
		is_on_starpoint = true
	elif !l_starpoint && is_on_starpoint:
		starpoint_entered.emit(l_starpoint)
		is_on_starpoint = false
		
	if l_button && !is_on_button:
		button_entered.emit(l_button)
		is_on_button = true
	elif !l_button && is_on_button:
		button_entered.emit(l_button)
		is_on_button = false


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


func change_bokocolor_of_dad() -> void: ## @experimental: For the Debug Cards test area
	if parent_bokobody:
		for block: Bokoblock in parent_bokobody.child_blocks:
			block.change_bokocolor()


func change_bokocolor() -> void: ## @experimental: For the Debug Cards test area
	animator.anim_bokocolor_changed()
	
	@warning_ignore("int_as_enum_without_cast")
	boko_color = boko_color + 1
	
	# TODO: uhhh
	if boko_color > GameUtil.BokoColor.PINK:
		boko_color = GameUtil.BokoColor.GREY
	elif boko_color == GameUtil.BokoColor.GREY:
		boko_color = GameUtil.BokoColor.AQUA
	
	_setup_node()
	check_state()
	
	if is_on_starpoint:
		Audio.play_starpoint_entered()

## @experimental: For the Debug Cards test area
##
## Such blessed method names
func get_out() -> void:
	if animator:
		animator.anim_removed()
		await get_tree().create_timer(0.55).timeout
		visible = false
		monitorable = false
		monitoring = false


func _set_as_center_block(is_center: bool) -> void:
	if is_center:
		sprite_block.texture = asset_center_block
		self.z_index = 1
	else:
		sprite_block.texture = asset_block
		self.z_index = 0
