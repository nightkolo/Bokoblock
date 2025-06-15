extends Button

var tween: Tween


func _ready() -> void:
	pivot_offset = size / 2
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	pressed.connect(anim_pressed)
	mouse_entered.connect(anim_entered)
	mouse_exited.connect(anim_exited)
	focus_entered.connect(anim_entered)
	focus_exited.connect(anim_exited)
	button_up.connect(func():
		pass
		)
	button_down.connect(func():
		pass
		)

func anim_pressed() -> void:
	var dur := 1.0
	
	Audio.ui_button_click.play()
	
	self.scale = Vector2(1.35, 0.95)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE * 1.11, dur)


func anim_entered() -> void:
	var dur := 1.0
	var scale_to := 1.11
	
	Audio.ui_button_hover.play()
	
	self_modulate = Color(Color.WHITE*1.2)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	
	scale.x = 0.6
	scale.y = 0.8
	
	tween.tween_property(self, "scale:x", scale_to, dur/3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:y", scale_to, dur).set_trans(Tween.TRANS_ELASTIC).set_delay(dur/9)
		
		
func anim_exited() -> void:
	if tween:
		tween.kill()
	
	self_modulate = Color(Color.WHITE*1.0)
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.9)
	
