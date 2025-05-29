extends Button
class_name BoardSelectButton

var tween: Tween
var board_id: int = 0
var board_checkmark: PackedScene = preload("res://interface/ui/board_checkmark.tscn")


func _ready() -> void:
	display_data()
	
	pivot_offset = size / 2
	
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

func display_data():
	board_id = self.name.to_int()
	
	var board_num: String = str(board_id)
	
	if !GameData.runtime_data.has(board_num):
		push_warning("Cannot display data. Key %s not found in GameData.runtime_data." % board_num)
		return
	
	if !(board_id >= 0 && board_id <= GameUtil.NUMBER_OF_BOARDS):
		push_warning("Cannot display data. Key %s is out of bounds from GameUtil.NUMBER_OF_BOARDS." % board_num)
		return
		
	if GameData.runtime_data[board_num]["completed"]:
		var check := board_checkmark.instantiate()
		add_child(check)


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
	var dur := 0.75
	var scale_to := Vector2.ONE * 1.15
	
	play_aud()
	
	self_modulate = Color(Color.WHITE*1.2)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", scale_to, dur).set_trans(Tween.TRANS_ELASTIC)
	
	
		
func play_aud():
	var aud := Audio.ui_button_hover.duplicate() as AudioStreamPlayer
	add_child(aud)
	aud.pitch_scale = randf_range(0.8, 1.2)
	aud.play()
	
	await aud.finished
	aud.queue_free()


func anim_exited():
	var dur := 0.75
	
	self_modulate = Color(Color.WHITE*1.0)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	
