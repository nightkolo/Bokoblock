extends Node2D

func _ready() -> void:
	var tween := create_tween().set_loops()

	tween.tween_property(self,"modulate",Color(Color.WHITE*2.0, 1.0),0.05).set_delay(1.0)
	tween.tween_property(self,"modulate",Color(Color.WHITE*1.0, 1.0),0.5)
