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
	button_up.connect(_held)
	button_down.connect(_rest)


func _held() -> void:
	set("theme_override_colors/font_outline_color",Color(Color.BLACK))
	
	
func _rest() -> void:
	set("theme_override_colors/font_outline_color",Color(Color.WHITE))


func anim_pressed() -> void:
	var dur := 1.1
	var scale_to := 1.11
	
	Audio.ui_option_toggle.play()
	
	self.scale = Vector2(1.35, 0.95)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	
	scale.x = 1.35
	scale.y = 0.75
	
	tween.tween_property(self, "scale", Vector2.ONE * scale_to, dur).set_trans(Tween.TRANS_ELASTIC)


func anim_entered() -> void:
	var dur := 1.1
	var scale_to := 1.11
	
	Audio.ui_button_hover.play()
	
	self_modulate = Color(Color.WHITE*1.2)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	
	scale.x = 1.35
	scale.y = 0.75
	
	tween.tween_property(self, "scale", Vector2.ONE * scale_to, dur).set_trans(Tween.TRANS_ELASTIC)
		
		
func anim_exited() -> void:
	var dur := 1.0
	
	if tween:
		tween.kill()
	
	self_modulate = Color(Color.WHITE*1.0)
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur)
	
