extends Node2D
class_name BoardNumber

@onready var label: Label = %Label
@onready var node_sprite: Node2D = $Node2D
@onready var sprite: Sprite2D = $Node2D/Sprite2D

@export var texture_purple: Texture2D = preload("res://assets/interface/move-counter-purple-01.png")
@export var texture_yellow: Texture2D = preload("res://assets/interface/move-counter-yellow-01.png")


func _ready() -> void:
	anim_idle()
	
	await get_tree().create_timer(0.1).timeout
	label.text = str(GameMgr.current_checkerboard_id) + "-" + str(GameMgr.current_stage_id)


func anim_idle():
	var dur_hover := 1.2
	var dur_rot := 2.2
	var mag_hover := 5.0 # magnitude
	var mag_rot := 17.5
	
	var tween = create_tween().set_loops()
	var tween_b = create_tween().set_loops()
	
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_b.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(node_sprite,"position:y", -mag_hover ,dur_hover).as_relative()
	tween.tween_property(node_sprite,"position:y", mag_hover ,dur_hover).as_relative()
	
	tween_b.tween_property(sprite,"rotation", deg_to_rad(-mag_rot), dur_rot)
	tween_b.tween_property(sprite,"rotation", deg_to_rad(0.0), dur_rot)
	
