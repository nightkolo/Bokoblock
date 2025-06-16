extends Button

var tween: Tween

var col_down: Color = Color(Color.WHITE*0.9, 1.0)
var col_up: Color = Color(Color.WHITE*1.2, 1.0)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	pivot_offset = size / 2.0
	self_modulate = col_down
	#size_flags_horizontal = SizeFlags.SIZE_SHRINK_CENTER
	
	self.add_to_group("UIButton")
	
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
	var dur := 1.0
	
	Audio.ui_button_click.play()
	
	scale = Vector2(1.2, 0.8)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur)


func anim_entered() -> void:
	var dur := 1.0
	Audio.ui_button_hover.play()
	
	self_modulate = col_up
	pivot_offset = Vector2(0.0, size.y / 2.0)
	scale = Vector2(1.25, 0.75)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur)
		
		
func anim_exited() -> void:
	self_modulate = Color(Color.WHITE*0.8, 1.0)
	pivot_offset = Vector2(0.0 , size.y/2)
