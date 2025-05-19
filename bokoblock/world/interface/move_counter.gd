## @deprecated
extends Node2D
class_name MoveCounter

@onready var label: Label = %Label
@onready var node_sprite: Node2D = $Node2D
@onready var sprite: Sprite2D = $Node2D/Sprite2D

@export var texture_purple: Texture2D = preload("res://assets/interface/move-counter-purple-01.png")
@export var texture_yellow: Texture2D = preload("res://assets/interface/move-counter-yellow-01.png")


#var label_sets: LabelSettings = preload("res://core/resources/ui/label_set_move_counter.tres")

func _ready() -> void:
	#label_sets.font_color = Color(Color.BLACK, 0.65)
	
	anim_idle()


#var tween_incre: Tween


#func anim_increment() -> void:
	#var dur := 0.4
	#
	#if tween_incre:
		#tween_incre.kill()
	#
	#tween_incre = get_tree().create_tween().set_parallel(true)
	#
	#sprite.scale = Vector2.ONE * 0.375
	#label.scale = Vector2.ONE * 1.5
	#
	#tween_incre.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#
	#tween_incre.tween_property(sprite,"scale",Vector2.ONE / 2.0, dur)
	#tween_incre.tween_property(label,"scale",Vector2.ONE, dur)
	#
#
#func anim_purple_starred() -> void:
	#sprite.texture = texture_purple
	#label_sets.font_color = Color(Color.WHITE, 0.75)
#
#
#func anim_yellow_starred() -> void:
	#sprite.texture = texture_yellow
	#label_sets.font_color = Color(Color.BLACK, 0.65)


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
	
