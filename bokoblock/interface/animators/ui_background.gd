## Under construction
extends CanvasLayer
class_name UIBackground

@onready var texture_bg: TextureRect = %TextureRect
@onready var node_texture_1: Node2D = %Texture1
@onready var node_texture_2: Node2D = %Texture2


func _ready() -> void:
	spin_bg()
	
		
func spin_bg() -> void:
	node_texture_2.rotation = deg_to_rad( randf() * 360.0)
	
	await get_tree().create_timer(0.1).timeout
	
	var tween = create_tween().set_loops()
	
	tween.tween_property(node_texture_2,"rotation", PI , 30.0).as_relative()
