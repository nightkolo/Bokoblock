extends Button

var tween: Tween


func _ready() -> void:
	pivot_offset = size / 2
	size_flags_horizontal = SizeFlags.SIZE_SHRINK_CENTER
	
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

func anim_pressed():
	var dur := 1.0
	
	Audio.ui_button_click.play()
	
	scale = Vector2(1.2, 0.8)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur)


func anim_entered():
	var dur := 1.0
	#var scale_to := Vector2.ONE * 1.15
	Audio.ui_button_hover.play()
	
	self_modulate = Color(Color.WHITE*1.2)
	pivot_offset = Vector2(  0.0 , size.y/2)
	scale = Vector2(1.25, 0.75)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur)
		
		
func anim_exited():
	#var dur := 0.75
	
	self_modulate = Color(Color.WHITE*1.0)
	pivot_offset = Vector2(0.0 , size.y/2)
	
	#if tween:
		#tween.kill()
		#
	#tween = create_tween().set_parallel(true)
	#tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	#tween.tween_property(self, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	
