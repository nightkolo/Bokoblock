## Under construction.
extends MarginContainer
class_name MonologText

signal letter_showing_started()
signal letter_showing_finished()
signal letter_showed()
signal next_monologue_entered(is_index: int)
signal boko_pose_set(is_pose: GameLogic.BokoPose)

@export_multiline var monologue_text: Array[String]
@export var boko_poses: Array[GameLogic.BokoPose]
@export_group("Modify")
@export_multiline var bbcode_default: String = "[b][font_size=25][outline_size=3][outline_color=#00000040]" ## @experimental
@export var auto_start_monologue: bool = false

@onready var bubble: NinePatchRect = %NinePatchRect
@onready var label: RichTextLabel = %Label

var label_text: String

var current_text: String = ""
var letter_index: int = 0
var letter_time: float = 0.04
var space_time: float = 0.08
var punctuation_time: float = 0.32
var speed_up_time: float = 0.01
var speed_it_up: bool = false

var current_line_index: int = 0
var can_advance_line: bool = false
var is_monolog_active: bool = false
var monolog_texts_size: int
var is_boogieing: bool = false ## @experimental
var shake_code: String = "[shake rate=12.5 level=10 connected=1]" ## @experimental

const MAX_BUBBLE_WIDTH = 270.0

var _tween_bubble: Tween
var _wait_bool: bool = false
var _letter_show_timer: Timer = Timer.new()
var _monolog_spawn_timer: Timer


func _ready() -> void:
	_letter_show_timer.one_shot = true
	add_child(_letter_show_timer)
	
	monolog_texts_size = monologue_text.size()
	
	bubble.pivot_offset = size / 2.0
	
	anim_bubble_bounce()
	
	letter_showing_finished.connect(func():
		speed_it_up = false
		can_advance_line = true
		
		label.self_modulate = Color(Color.WHITE,1.0)
		)
	_letter_show_timer.timeout.connect(func():
		_show_letter()
		letter_showed.emit()
		)
	letter_showed.connect(anim_bubble_bounce)
	
	if auto_start_monologue:
		show_text(monologue_text[current_line_index])
		
		next_monologue_entered.emit(current_line_index)
		boko_pose_set.emit(boko_poses[current_line_index])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_next_monolog"):
		if is_monolog_active:
			if can_advance_line:
				
				current_line_index += 1
				if current_line_index < monologue_text.size() && current_line_index < boko_poses.size():
					show_text(monologue_text[current_line_index])
					next_monologue_entered.emit(current_line_index)
					boko_pose_set.emit(boko_poses[current_line_index])
					
				else:
					_monolog_spawn_timer.queue_free()
					close()
					
			elif _has_dialog_spawned():
				speed_it_up = true
				
		else:
			show_text(monologue_text[current_line_index])
			
			next_monologue_entered.emit(current_line_index)
			boko_pose_set.emit(boko_poses[current_line_index])


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
	label.text = bbcode_default + text_to_show
	
	label_text = label.get_parsed_text()
	
	modulate = Color(Color.WHITE, 1.0)
	_show_letter()
	
	_monolog_spawn_timer.start()
	letter_showing_started.emit()


func _show_letter() -> void:
	letter_index += 1
	
	label.visible_characters = letter_index + 1
	
	if letter_index < label_text.length():
		var current_letter := label_text[letter_index]
		
		if speed_it_up:
			_letter_show_timer.start(speed_up_time)
			
		else:
			match current_letter:
				
				"!", ",", ".", "?":
					_letter_show_timer.start(punctuation_time)
					#anim_shake()
 					
				" ":
					_letter_show_timer.start(space_time)
					
				_:
					_letter_show_timer.start(letter_time)
					
	else:
		letter_showing_finished.emit()


func _has_dialog_spawned() -> bool:
	#print(_monolog_spawn_timer.time_left)
	return _monolog_spawn_timer.time_left == 0.0


func anim_bubble_bounce() -> void:
	var dur := 1.0
	var rot_to: float = (randf()-0.5)*2.5
	
	if _tween_bubble:
		_tween_bubble.kill()
		
	_tween_bubble = create_tween().set_parallel(true)
	_tween_bubble.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	_tween_bubble.tween_property(bubble,"rotation_degrees",rot_to,dur/20.0)
	_tween_bubble.tween_property(bubble,"scale",Vector2.ONE*1.05,dur/20.0)
	_tween_bubble.tween_property(bubble,"scale",Vector2.ONE,dur).set_delay(dur/20.0)
	_tween_bubble.tween_property(bubble,"rotation_degrees",0.0,dur*2.0).set_trans(Tween.TRANS_ELASTIC).set_delay(dur/20.0)


## @experimental
func anim_shake() -> void:
	if is_boogieing:
		return
	
	is_boogieing = true
	
	label.self_modulate = Color(Color.WHITE,0.0)
	#shaky_label.self_modulate = Color(Color.WHITE,1.0)
	await get_tree().create_timer(0.18).timeout
	label.self_modulate = Color(Color.WHITE,1.0)
	#shaky_label.self_modulate = Color(Color.WHITE,0.0)
	
	is_boogieing = false
