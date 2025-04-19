extends StaticBody2D
class_name SleepingBlock

var _sprite: Sprite2D

func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	
	_sprite = get_node_or_null("Sprite2D")
	
	if _sprite:
		var dur := 2.0
		var tween := create_tween().set_loops()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		
		tween.tween_property(_sprite, "scale:x", 1.05 / 2.0, dur)
		tween.tween_property(_sprite, "scale:y", 0.95 / 2.0, dur)
		tween.tween_property(_sprite, "scale:x", 0.95 / 2.0, dur).set_delay(dur)
		tween.tween_property(_sprite, "scale:y", 1.05 / 2.0, dur).set_delay(dur)
