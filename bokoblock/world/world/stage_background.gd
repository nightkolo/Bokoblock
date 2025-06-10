## Under construction
extends CanvasLayer
class_name Background

@export var apply_custom_color: bool = false ## @experimental
@export var custom_color: Color
@export_range(0.0, 1.0, 0.05) var background_dim: float = 0.25
	#get:
		#return background_dim
	#set(value):
		#bg_dim.self_modulate = Color(Color.WHITE, value)
		#background_dim = value

@onready var texture_bg: TextureRect = $Texture/TextureRect
@onready var texture_node: Node2D = $Texture
@onready var bg_dim: Sprite2D = $BGDim


func _ready() -> void:
	_setup_node()
	
	if apply_custom_color:
		texture_bg.self_modulate = custom_color


func _setup_node() -> void:
	spin_bg()
	
	bg_dim.self_modulate = Color(Color.WHITE, background_dim)
		
		
func spin_bg() -> void:
	var spin_dir: float
	
	texture_node.rotation = deg_to_rad( randf() * 360.0)
	
	await get_tree().create_timer(0.1).timeout
	
	if BokoMath.is_even(GameMgr.current_board_id):
		spin_dir = 1
	else:
		spin_dir = -1
	
	var tween = create_tween().set_loops()
	
	tween.tween_property(texture_node,"rotation", PI * spin_dir , 30.0).as_relative()
