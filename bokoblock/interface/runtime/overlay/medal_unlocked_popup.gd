extends CanvasLayer
class_name MedalUnlockedPopup

@onready var label: Label = %Label

var _tween: Tween


func _ready() -> void:
	GameMgr.current_medal_notifier = self
	
	visible = false
	

func anim_medal_unlocked() -> void:
	var dur := 1.0
	
	if _tween:
		_tween.kill()
	
	label.scale.x = 0.0
	label.self_modulate = Color(Color.WHITE, 0.0)
	visible = true
	
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(label, "self_modulate", Color(Color.WHITE, 1.0), dur / 2.0)
	_tween.tween_property(label, "scale:x", 1.0, dur).set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(label, "self_modulate", Color(Color.WHITE, 0.0), dur * 2.0).set_delay(dur)
	
	await get_tree().create_timer(dur * 4.0).timeout
	
	visible = false
