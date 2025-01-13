## Under construction.
extends Node2D
class_name ChibiBoko

signal letter_showing_started()
signal letter_showing_finished()
signal letter_showed()

enum BubbleAlign {LEFT = 0, RIGHT = 1}

@export_multiline var info_text: String
@export var bubble_align: BubbleAlign
@export_group("Modify")
@export var animate_boko: bool = true
@export var await_time: float = 0.75
@export var auto_start_text: bool = true

@onready var bubble: NinePatchRect = $NinePatchRect
@onready var label: RichTextLabel = $RichTextLabel
@onready var chibi_boko: CharacterChibiBoko = $CharacterChibiBoko
@onready var audio: AudioStreamPlayer = $Speech

var displayed_text: String
var current_text: String = ""
var letter_index: int = 0
var letter_time: float = 0.05
var space_time: float = 0.09
var punctuation_time: float = 0.4

var is_chibi_boko_speaking: bool = false:
	set(value):
		if value != is_chibi_boko_speaking:
			if value && chibi_boko:
				chibi_boko.start_speaking()
			else:
				chibi_boko.pause_speaking()
			is_chibi_boko_speaking = value
var is_info_active: bool = false
var monolog_texts_size: int

const STAGE_COMPLETE_TEXT = "Well done!"
const MAX_BUBBLE_WIDTH = 270.0
const _BUBBLE_MARGIN = Vector2.ONE * 35.0
const _LABEL_MARGIN = Vector2.ONE * 10.0

var _tween_bubble: Tween
var _letter_show_timer: Timer = Timer.new()


func _ready() -> void:
	_letter_show_timer.one_shot = true
	add_child(_letter_show_timer)
	
	bubble.visible = false
	label.scale = Vector2(0.95,1.0)
	
	GameLogic.bokobody_entered_starpoint.connect(func():
		if !GameLogic.has_won:
			chibi_boko.anim_excited()
		)
	GameLogic.bokobody_exited_starpoint.connect(func():
		if !GameLogic.has_won:
			chibi_boko.anim_unexcited()
		)
	GameMgr.game_just_ended.connect(func():
		show_text(STAGE_COMPLETE_TEXT)
		
		if chibi_boko && animate_boko && GameLogic.has_won:
			chibi_boko.stop_speaking()
			chibi_boko.be_happy()
		)
	
	letter_showing_started.connect(func():
		if chibi_boko && animate_boko && !GameLogic.has_won:
			chibi_boko.start_speaking()
		)
	
	letter_showing_finished.connect(func():
		is_info_active = false
		
		if chibi_boko && animate_boko && !GameLogic.has_won:
			chibi_boko.stop_speaking()
			chibi_boko.be_neutral()
		
		label.size += _LABEL_MARGIN
		anim_bubble_bounce()
		)
		
	_letter_show_timer.timeout.connect(func():
		_show_letter()
		letter_showed.emit()
		)
	
	if auto_start_text && info_text != "":
		await get_tree().create_timer(await_time).timeout
		show_text(info_text)


func _process(_delta: float) -> void:
	#print(label.size)
	
	bubble.size = label.size + _BUBBLE_MARGIN


func close() -> void:
	if is_info_active:
		label.text = ""
		
		is_info_active = false
	

func show_text(text_to_show: String) -> void:
	is_info_active = true
	letter_index = 0
	label.visible = false
	bubble.visible = false
	
	label.visible_characters = 0
	label.size = Vector2.ZERO
	bubble.size = Vector2.ZERO
	
	current_text = text_to_show
	label.text = " " + current_text
	displayed_text = label.get_parsed_text()
	
	label.visible_characters = 0
	label.size = Vector2.ZERO
	bubble.size = Vector2.ZERO
	
	_show_letter()
	letter_showing_started.emit()
	
	label.modulate = Color(Color.WHITE,1.0)
	label.visible = true
	bubble.visible = true


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
				
				#play_speech(current_text[letter_index])
					
	else:
		letter_showing_finished.emit()


func anim_bubble_bounce():
	var dur := 1.0
	var bounce_to := 1.3
	
	var p_size := label.size
	var offset: Vector2
	
	match bubble_align:
		BubbleAlign.LEFT:
			offset = Vector2(0.0,p_size.y/2.0)
		BubbleAlign.RIGHT:
			offset = Vector2(p_size.x,p_size.y/2.0)
	
	bubble.pivot_offset = offset
	bubble.scale = Vector2.ONE * bounce_to
	
	if _tween_bubble:
		_tween_bubble.kill()
	
	_tween_bubble = create_tween()
	_tween_bubble.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	_tween_bubble.tween_property(bubble,"scale",Vector2.ONE,dur)


func play_speech(letter: String = "") -> void:
	var aud := audio.duplicate() as AudioStreamPlayer
	aud.volume_db = -30.0
	aud.pitch_scale += randf_range(-0.1,0.1)
	get_tree().root.add_child(aud)
	
	#print(letter)
	
	if letter in ["a", "e", "i", "o", "u"]:
		aud.pitch_scale += 0.3
		
	#elif letter in ["!", ",", ".", "?"]:
		#aud.pitch_scale -= 0.5
		#aud.volume_db += 5.0 
		
	aud.play()
	await aud.finished
	aud.queue_free()
