## Preferably use [url]res://world/interface/board_info.tscn
extends Node2D
class_name BoardInfo

signal letter_showing_started()
signal letter_showing_finished()
signal letter_showed()

@export_multiline var info_text: String
@export_group("Modify")
@export var animate: bool = true
@export var auto_start_text: bool = true
@export_range(0, 1, 0.05, "or_greater") var await_time: float = 0.75
@export var colli_shape: Shape2D = preload("res://core/resources/game/chibi_boko_speech_bubble_collision_area.tres")

@onready var bubble: NinePatchRect = $SpeechBubble
@onready var label: Label = $TextBubble
@onready var chibi_boko: CharacterChibiBoko = $CharacterChibiBoko
@onready var audio: AudioStreamPlayer = $Speech
@onready var colli_area: Area2D = $Area2D
@onready var button: Button = $Button

var displayed_text: String
var current_text: String = ""
var letter_index: int = 0
var letter_time: float = 0.025
var space_time: float = 0.045
var punctuation_time: float = 0.2

var is_info_active: bool = false
var is_chibi_boko_speaking: bool = false:
	get:
		return is_chibi_boko_speaking
	set(value):
		if value != is_chibi_boko_speaking:
			if value:
				chibi_boko.start_speaking()
			else:
				chibi_boko.pause_speaking()
		is_chibi_boko_speaking = value

const BOARD_COMPLETE_TEXT = "Well done!"

var _tween_bubble_a: Tween
var _tween_bubble_b: Tween
var _tween_fade: Tween

var _letter_show_timer: Timer = Timer.new()
var _excitement_timer: Timer = Timer.new()

const _BUBBLE_MARGIN = Vector2.ONE * 35.0
const _LABEL_MARGIN = Vector2.ONE * 10.0


func _ready() -> void:
	_letter_show_timer.one_shot = true
	_excitement_timer.one_shot = true
	_excitement_timer.wait_time = 3.0
	
	add_child(_letter_show_timer)
	add_child(_excitement_timer)
	
	bubble.visible = false
	bubble.modulate = Color(Color.WHITE, 0.0)
	label.scale = Vector2(0.95,1.0)
	
	colli_shape.size = Vector2.ONE * 20.0
	
	colli_area.area_entered.connect(_on_colli_area_interacted)
	colli_area.area_exited.connect(_on_colli_area_interacted)
	
	label.resized.connect(func():
		bubble.size = label.size + _BUBBLE_MARGIN
		colli_shape.size = label.size + _BUBBLE_MARGIN + (Vector2.ONE * 10.0)
		colli_area.position.x = (colli_shape.size.x / 2.0) + 30.0
		)
	
	button.pressed.connect(func():
		chibi_boko.anim_wobble_top_hat(10.0, 1.5)
		)
	
	if animate:
		if !_is_info_text_added():
			chibi_boko.pose_asleep()
		
		GameLogic.body_entered_starpoint.connect(func():
			if !GameLogic.has_won:
				chibi_boko.anim_excite(true)
				
				_excitement_timer.start()
			)
			
		GameLogic.body_exited_starpoint.connect(func():
			if !GameLogic.has_won:
				if _is_info_text_added():
					chibi_boko.anim_excite(false)
			)
			
		GameMgr.game_just_ended.connect(func():
			show_text(BOARD_COMPLETE_TEXT)
			
			if GameLogic.has_won:
				chibi_boko.stop_speaking()
				chibi_boko.pose_happy()
			)
		
		letter_showing_started.connect(func():
			if !GameLogic.has_won:
				chibi_boko.start_speaking()
			)
		
		letter_showing_finished.connect(func():
			is_info_active = false
			
			if !GameLogic.has_won:
				chibi_boko.stop_speaking()
				chibi_boko.pose_neutral()
			
			label.size += _LABEL_MARGIN
			anim_bubble_bounce()
			)
	
	_letter_show_timer.timeout.connect(func():
		_show_letter()
		letter_showed.emit()
		)
	
	_excitement_timer.timeout.connect(func():
		if !GameLogic.has_won && !_is_info_text_added():
			chibi_boko.pose_asleep()
		)
	
	if auto_start_text && _is_info_text_added():
		await get_tree().create_timer(await_time).timeout
		show_text(info_text)


func close() -> void:
	if is_info_active:
		label.text = ""
		
		is_info_active = false
	

func show_text(text_to_show: String) -> void:
	is_info_active = true
	letter_index = 0
	label.visible = false
	bubble.visible = false
	
	current_text = text_to_show
	label.text = " " + current_text
	displayed_text = label.text
	
	label.visible_characters = 0
	label.size = Vector2.ZERO
	bubble.size = Vector2.ZERO
	
	_show_letter()
	letter_showing_started.emit()
	
	label.modulate = Color(Color.WHITE,1.0)
	label.visible = true
	bubble.visible = true
	anim_bubble_pop_up()


func _show_letter() -> void:
	letter_index += 1
	
	label.visible_characters = letter_index + 1
	
	if letter_index < displayed_text.length() - 1:
		var current_letter := displayed_text[letter_index]
		
		#play_speech(current_text[letter_index])
		
		match current_letter:
			
			"!", ",", ".", "?":
				is_chibi_boko_speaking = false
				_letter_show_timer.start(punctuation_time)
				
			" ":
				_letter_show_timer.start(space_time)
				
			_:
				is_chibi_boko_speaking = true
				_letter_show_timer.start(letter_time)
				
				play_speech(current_text[letter_index])
					
	else:
		letter_showing_finished.emit()


func change_opacity(fade: bool) -> void:
	var dur := 0.2
	
	if _tween_fade:
		_tween_fade.kill()
	
	_tween_fade = create_tween()
	
	if fade:
		_tween_fade.tween_property(bubble, "modulate", Color(Color.WHITE, 0.5), dur)
	else:
		_tween_fade.tween_property(bubble, "modulate", Color(Color.WHITE, 0.85), dur)


func _on_colli_area_interacted(p_area: Area2D) -> void:
	await get_tree().create_timer(0.08).timeout
		
	change_opacity(p_area.get_overlapping_areas().size() > 0)


func _is_info_text_added() -> bool:
	return info_text != ""


func anim_bubble_pop_up() -> void:
	var dur := 0.45
	
	if _tween_bubble_b:
		_tween_bubble_b.kill()
		
	bubble.scale = -Vector2.ONE
	bubble.modulate = Color(Color.WHITE, 0.0)
	
	_tween_bubble_b = create_tween().set_parallel(true)
	_tween_bubble_b.set_ease(Tween.EASE_OUT)
	_tween_bubble_b.tween_property(bubble,"modulate",Color(Color.WHITE, 1.0),dur/1.8)
	_tween_bubble_b.tween_property(bubble,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)


func anim_bubble_bounce() -> void:
	var dur := 0.4
	var bounce_to := 1.1
	var offset: Vector2
	
	bubble.pivot_offset = offset
	bubble.scale = Vector2.ONE * bounce_to
	
	if _tween_bubble_a:
		_tween_bubble_a.kill()
	
	_tween_bubble_a = create_tween()
	_tween_bubble_a.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	_tween_bubble_a.tween_property(bubble,"scale",Vector2.ONE,dur)


func play_speech(letter: String = "") -> void:
	var aud := audio.duplicate() as AudioStreamPlayer
	aud.volume_db = -8.5
	aud.pitch_scale += randf_range(-0.2,0.2)
	get_tree().root.add_child(aud)
	
	if letter in ["a", "e", "i", "o", "u"]:
		aud.pitch_scale += 0.3
		
	#elif letter in ["!", ",", ".", "?"]:
		#aud.pitch_scale -= 0.5
		#aud.volume_db += 5.0 
		
	aud.play()
	await aud.finished
	aud.queue_free()
