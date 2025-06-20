extends Node2D
class_name BoardNumber

@export var texture_purple: Texture2D = preload("res://assets/interface/move-counter-purple-01.png")
@export var texture_yellow: Texture2D = preload("res://assets/interface/move-counter-yellow-01.png")
@export var board_number: LabelSettings = preload("res://core/resources/visuals/board_number.tres")

@onready var label: Label = %Label
@onready var node_sprite: Node2D = $Node2D
@onready var sprite: Sprite2D = $Node2D/Sprite2D


func _ready() -> void:
	anim_idle()
	
	modulate = Color(Color.WHITE, 0.0)
	label.label_settings = board_number
	
	await get_tree().create_timer(0.1).timeout
	
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 1.0), 1.0)
	
	match GameMgr.checkerboard_id:
		
		1:
			sprite.texture = texture_yellow
			board_number.font_color = Color(Color.BLACK, 0.75)
	
		2:
			sprite.texture = texture_purple
			board_number.font_color = Color(Color.WHITE, 0.75)
	
	label.text = str(GameMgr.checkerboard_id) + "-" + str(GameMgr.board_id)


func anim_idle() -> void:
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
	
