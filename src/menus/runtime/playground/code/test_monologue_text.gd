## Under construction.
extends MarginContainer
class_name MonologText

signal letter_showing_started()
signal letter_showing_finished()
signal letter_showed()

@export var auto_start_monologue: bool = false
@export_multiline var monologue_text: Array[String]

@onready var label: RichTextLabel = $Label
@onready var shaky_label: RichTextLabel = $ShakyLabel


var label_text: String

var current_text: String = ""
var letter_index: int = 0
var letter_time: float = 0.08
var space_time: float = 0.16
var punctuation_time: float = 0.4
var speed_up_time: float = 0.01
var speed_it_up: bool = false

var current_line_index: int = 0
var can_advance_line: bool = false
var is_monolog_active: bool = false
var monolog_texts_size: int

const MAX_BUBBLE_WIDTH = 270.0

var _letter_show_timer: Timer = Timer.new()
var _monolog_spawn_timer: Timer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_next_monolog"):
		if is_monolog_active:
			if can_advance_line:
				
				current_line_index += 1
				if current_line_index < monologue_text.size():
					show_text(monologue_text[current_line_index])
					
				else:
					_monolog_spawn_timer.queue_free()
					close()
					
			elif _has_dialog_spawned():
				speed_it_up = true
				
		else:
			show_text(monologue_text[current_line_index])


func _has_dialog_spawned() -> bool:
	print(_monolog_spawn_timer.time_left)
	return _monolog_spawn_timer.time_left == 0.0


func _ready() -> void:
	_letter_show_timer.one_shot = true
	add_child(_letter_show_timer)
	
	monolog_texts_size = monologue_text.size()
	
	letter_showing_finished.connect(func():
		speed_it_up = false
		can_advance_line = true
		
		label.self_modulate = Color(Color.WHITE,1.0)
		shaky_label.self_modulate = Color(Color.WHITE,0.0)
		)
	_letter_show_timer.timeout.connect(func():
		_show_letter()
		letter_showed.emit()
		)
		
	if auto_start_monologue:
		show_text(monologue_text[current_line_index])


func close() -> void:
	if is_monolog_active:
		label.text = ""
		
		current_line_index = 0
		is_monolog_active = false
	

func show_text(text_to_show: String) -> void:
	_monolog_spawn_timer = Timer.new()
	_monolog_spawn_timer.wait_time = 0.25
	_monolog_spawn_timer.one_shot = true
	add_child(_monolog_spawn_timer)
	
	is_monolog_active = true
	can_advance_line = false
	letter_index = 0
	
	modulate = Color(Color.WHITE, 0.0)
	current_text = text_to_show
	#info_text.horizontal_alignment = align
	label.text = text_to_show
	shaky_label.text = shake_code + text_to_show
	#shaky_label.visible = false
	shaky_label.self_modulate = Color(Color.WHITE,0.0)
	
	label_text = label.get_parsed_text()
	
	modulate = Color(Color.WHITE, 1.0)
	_show_letter()
	
	_monolog_spawn_timer.start()
	letter_showing_started.emit()


var is_boogieing: bool = false
var shake_code: String = "[shake rate=12.5 level=10 connected=1]"

# TODO: make shaky_label behind label and modulate = black. and choose a good font.
func anim_shake() -> void:
	if is_boogieing:
		return
	
	is_boogieing = true
	
	#label.text = shake_code + current_text
	label.self_modulate = Color(Color.WHITE,0.0)
	shaky_label.self_modulate = Color(Color.WHITE,1.0)
	await get_tree().create_timer(0.18).timeout
	#label.text = current_text
	label.self_modulate = Color(Color.WHITE,1.0)
	shaky_label.self_modulate = Color(Color.WHITE,0.0)
	
	is_boogieing = false


func _show_letter() -> void:
	#info_text.text += current_text[letter_index]
	letter_index += 1
	
	label.visible_characters = letter_index + 1
	shaky_label.visible_characters = letter_index + 1
	
	if letter_index < label_text.length():
		var current_letter := label_text[letter_index]
		
		if speed_it_up:
			label.self_modulate = Color(Color.WHITE,1.0)
			shaky_label.self_modulate = Color(Color.WHITE,0.0)
			#label.visible = true
			#shaky_label.visible = false
			_letter_show_timer.start(speed_up_time)
			
		else:
			match current_letter:
				
				"!", ",", ".", "?":
					_letter_show_timer.start(punctuation_time)
					anim_shake()
 					
				" ":
					_letter_show_timer.start(space_time)
					
				_:
					_letter_show_timer.start(letter_time)
					
	else:
		letter_showing_finished.emit()
