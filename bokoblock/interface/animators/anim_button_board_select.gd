extends Button
class_name BoardSelectButton

var tween: Tween
var board_id: int = 0
@onready var bcheck: Node2D = $Bcheck


func _ready() -> void:
	display_data()
	
	GameMgr.game_data_saved.connect(display_data)
	
	self.add_to_group("UIBoardButton")
	
	pivot_offset = size / 2.0
	
	pressed.connect(anim_pressed)
	mouse_entered.connect(anim_entered)
	mouse_exited.connect(anim_exited)
	focus_entered.connect(anim_entered)
	focus_exited.connect(anim_exited)


func display_data() -> void:
	board_id = self.name.to_int()
	
	var board_num: String = str(board_id)

	if !GameData.runtime_data.has(board_num):
		push_warning("Cannot display data. Key %s not found in GameData.runtime_data." % board_num)
		return
	
	if !(board_id >= 0 && board_id <= GameUtil.NUMBER_OF_BOARDS):
		push_warning("Cannot display data. Key %s is out of bounds from GameUtil.NUMBER_OF_BOARDS." % board_num)
		return
	
	bcheck.visible = GameData.runtime_data[board_num]["completed"] == true


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
	var dur := 0.75
	var scale_to := Vector2.ONE * 1.15
	
	play_aud()
	
	self_modulate = Color(Color.WHITE*1.2)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", scale_to, dur).set_trans(Tween.TRANS_ELASTIC)
	
		
func play_aud() -> void:
	var aud := Audio.ui_button_hover.duplicate() as AudioStreamPlayer
	add_child(aud)
	aud.pitch_scale = randf_range(0.8, 1.2)
	aud.play()
	
	await aud.finished
	aud.queue_free()


func anim_exited() -> void:
	var dur := 0.75
	
	self_modulate = Color(Color.WHITE*1.0)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	
