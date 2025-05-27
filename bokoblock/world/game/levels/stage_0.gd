extends Node2D
class_name Monolog

signal monolog_line_entered(is_index: int)
signal boko_pose_set(is_pose: BokoPoses)

signal letter_showing_started()
signal letter_showing_finished()
signal letter_showed()

enum BokoPoses {
	NEUTRAL = 0,
	WOKE = 1,
	EXCITED = 69,
	CONFUSED = 2,
	DEADPAN = 3,
	ONE_EYE_OPEN_WHEN_IM_SLEEPIN = 4
}

@export_multiline var monolog_lines: Array[String] = [
	"[font_size=48][shake]Wha- huh?",

	"Oh, a new specimen,
I've heard [rainbow freq=0.4 sat=0.2 val=1.0 speed=0.5][font_size=36]great[/font_size][/rainbow] things about you.",
	
	"[color=lightgray]Why hello there![/color]
My name is [color=yellow][wave amp=25.0 freq=5.0 connected=0.0][font_size=35]Boko[/font_size][/wave][/color],
call me... [i]uhh",
	
	"Listen, [color=yellow][font_size=35]Boko[/font_size][/color]'s just fine, alright?",
	
	"[rainbow sat=0.2 freq=0.4 val=1.0][tornado radius=1.0 freq=5.0]Are you a thinky type?[/tornado][/rainbow] I would like to play a [shake][color=yellow]game[/color][/shake] with you!",
	
	"Don't get twisted,
I got no mouth so, I won't bite",
	
	"I’ll be your guide, guru, and occasionally confused observer!",
	
	"Get your fingers ready,
Let's slide onto Board 1-1!"
]
@export var monolog_poses: Array[BokoPoses]

@onready var top_hat_man: CharacterChibiBoko = $CharacterChibiBoko

@onready var label: RichTextLabel = %RichTextLabel

@onready var audio_speech: AudioStreamPlayer = $Node/Speech
@onready var audio_click: AudioStreamPlayer = $Node/Click


var letter_time: float = 0.04
var space_time: float = 0.08
var punctuation_time: float = 0.32
var speed_up_time: float = 0.005
var speed_it_up: bool = false

var is_monolog_active: bool = false
var can_advance_line: bool = false

## Text with BBCode
var raw_text: String
## Text with no BBCode
var displayed_text: String

const BBCODE_DEFAULT = "[center][tornado radius=0.5 freq=1.0][wave amp=8.0 freq=-5.0]"

var _letter_index: int = 0
var _current_line_index: int
var _monolog_spawn_timer: Timer
var _letter_show_timer: Timer = Timer.new()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_next_monolog"):
		goto_next_monolog()


func goto_next_monolog():
	if !is_monolog_active:
		start()
		return
		
	if can_advance_line:
		audio_click.play()
		
		_current_line_index += 1
		
		if _current_line_index < monolog_lines.size() && _current_line_index < monolog_poses.size():
			show_text(monolog_lines[_current_line_index])
			monolog_line_entered.emit(_current_line_index)
			boko_pose_set.emit(monolog_poses[_current_line_index])
			
		else:
			_monolog_spawn_timer.queue_free()
			stop()
			
	elif _has_dialog_spawned():
		speed_it_up = true


func _ready() -> void:
	_letter_show_timer.one_shot = true
	add_child(_letter_show_timer)
	
	top_hat_man.pose_asleep()
	
	boko_pose_set.connect(func(is_pose: BokoPoses):
		match is_pose:
			
			BokoPoses.NEUTRAL, BokoPoses.ONE_EYE_OPEN_WHEN_IM_SLEEPIN, BokoPoses.DEADPAN:
				# TODO: Play audio
				top_hat_man.pose_neutral()
				
			BokoPoses.WOKE, BokoPoses.CONFUSED:
				top_hat_man.pose_woke()
				
			BokoPoses.EXCITED:
				top_hat_man.pose_happy()
		)
	
	letter_showing_finished.connect(func():
		speed_it_up = false
		can_advance_line = true
		
		label.self_modulate = Color(Color.WHITE,1.0)
		)
	
	_letter_show_timer.timeout.connect(func():
		_show_letter()
		letter_showed.emit()
		)
	
	#anim_loop_test()
	#start()


func start():
	if !is_monolog_active:
		show_text(monolog_lines[_current_line_index])
			
		monolog_line_entered.emit(_current_line_index)
		boko_pose_set.emit(monolog_poses[_current_line_index])


func stop() -> void:
	if is_monolog_active:
		label.text = ""
		
		_current_line_index = 0
		is_monolog_active = false


func show_text(text_to_show: String) -> void:
	if _monolog_spawn_timer != null:
		_monolog_spawn_timer.queue_free()
	
	_monolog_spawn_timer = Timer.new()
	_monolog_spawn_timer.wait_time = 0.25
	_monolog_spawn_timer.one_shot = true
	add_child(_monolog_spawn_timer)
	
	is_monolog_active = true
	can_advance_line = false
	_letter_index = 0

	raw_text = text_to_show
	label.text = BBCODE_DEFAULT + text_to_show
	displayed_text = label.get_parsed_text()
	
	_show_letter()
	
	_monolog_spawn_timer.start()
	letter_showing_started.emit()


func _show_letter() -> void:
	label.visible_characters = _letter_index + 1
	
	_letter_index += 1
	
	if _letter_index < displayed_text.length():
		var current_letter := displayed_text[_letter_index]
		

		if speed_it_up:
			_letter_show_timer.start(speed_up_time)
			
		else:
			play_speech(displayed_text[_letter_index])
			
			match current_letter:
				
				"!", ",", "?":
					_letter_show_timer.start(punctuation_time)
 					
				" ":
					_letter_show_timer.start(space_time)
				
				".":
					_letter_show_timer.start(letter_time)
				
				_:
					_letter_show_timer.start(letter_time)
					
	else:
		letter_showing_finished.emit()


func play_speech(letter: String = "") -> void:
	var aud := audio_speech.duplicate() as AudioStreamPlayer
	aud.volume_db = -5.0
	aud.pitch_scale += randf_range(-0.1,0.1)
	add_child(aud)
	
	if letter in ["a", "e", "i", "o", "u"]:
		aud.pitch_scale += 0.3
		
	aud.play()
	await aud.finished
	aud.queue_free()


func _has_dialog_spawned() -> bool:
	return _monolog_spawn_timer.time_left == 0.0


func anim_loop_test() -> void: ## @experimental
	top_hat_man.pose_happy()
	
	await get_tree().create_timer(2.5).timeout
	
	top_hat_man.pose_asleep()

	await get_tree().create_timer(2.5).timeout
	
	top_hat_man.pose_woke()

	await get_tree().create_timer(2.5).timeout
	
	top_hat_man.pose_neutral()

	await get_tree().create_timer(2.5).timeout
	
	anim_loop_test()
