extends CanvasLayer
class_name UIBackground

@export var spin: bool = true ## @experimental

@onready var texture_bg: TextureRect = %TextureRect
@onready var node_texture_1: Node2D = %Texture1
@onready var node_texture_2: Node2D = %Texture2


func _ready() -> void:
	if spin:
		spin_bg()
	else:
		oscillate_bg()
	
		
func spin_bg() -> void:
	node_texture_2.rotation = deg_to_rad(randf() * 360.0)
	
	await get_tree().create_timer(0.1).timeout
	
	var tween = create_tween().set_loops()
	
	tween.tween_property(node_texture_2,"rotation", PI , 30.0).as_relative()


func oscillate_bg() -> void: ## @experimental
	var mag := 10.0
	var dur := 5.0
	
	node_texture_1.rotation_degrees = 45.0
	
	var tween = create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(node_texture_2,"rotation_degrees", -mag , dur)
	tween.tween_property(node_texture_2,"rotation_degrees", mag , dur)
	
