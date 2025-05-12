## Under Construction
extends Area2D
class_name SwitchBlocks

# TODO: Has issues when interacting with two Buttons of same BokoColor of Switch Block

# TODO: Proposing full behavior change: Make so it only activates once, to cut down on the complexity of the code.

signal has_opened(is_open: bool)

@export var switch_type_decorator: GameUtil.SwitchTypeDecorator
@export_group("Assets")
@export var texture_cross: Texture = preload("res://assets/objects/switch-block-head-cross.png")
@export var texture_square: Texture = preload("res://assets/objects/switch-block-head-square.png")

@onready var child_switch_blocks: Array[Node] = get_children()

var is_body_intersecting: bool
var body_intersecting: Bokobody
var is_open: bool:
	get:
		return is_open
	set(value):
		if value != is_open:
			has_opened.emit(value)
		is_open = value

var _tween: Tween
var _tween_pulse: Tween


func _ready() -> void:
	_setup_node()
	
	has_opened.connect(anim_open_or_close)


func _setup_node():
	for switch_block: SwitchBlock in child_switch_blocks:
		match switch_type_decorator:
			
			GameUtil.SwitchTypeDecorator.Cross:
				switch_block.sprite_head.texture = texture_cross
				
			GameUtil.SwitchTypeDecorator.Square:
				switch_block.sprite_head.texture = texture_square


func open(open_or_close: bool = !is_open) -> void:
	if open_or_close != is_open:
		is_open = open_or_close
		
		for switch_block: SwitchBlock in child_switch_blocks:
			switch_block.set_deferred("disabled", is_open)
		
		await GameMgr.process_waittime()
		
		if is_open == false:
			check_intersects()

	
func anim_open_or_close(open_or_close: bool) -> void:
	# TODO: Issue with animation when constantly switching
	
	var dur_bounce := 0.95
	var dur_open := 0.05
	var up := Vector2.ONE / 2.0
	var down := Vector2.ONE * 1.5
	var pulse_to := 1.75
	var op: float
	
	if _tween:
		_tween.kill()
	if _tween_pulse:
		_tween_pulse.kill()
		
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_pulse = create_tween().set_parallel(!open_or_close)
	_tween_pulse.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	for switch_block: SwitchBlock in child_switch_blocks:
		if open_or_close:
			switch_block.sprite_base.scale = down
			switch_block.sprite_head.scale = up
			op = 0.4
		else:
			switch_block.sprite_base.scale = up
			switch_block.sprite_head.scale = down
			op = 1.0
		
		_tween.tween_property(switch_block.sprite_base,"scale",Vector2.ONE,dur_bounce)
		_tween.tween_property(switch_block.sprite_head,"scale",Vector2.ONE,dur_bounce)
		
		_tween_pulse.tween_property(switch_block.node_sprite,"modulate",Color(Color.WHITE*pulse_to, 1.0),dur_open)
		_tween_pulse.tween_property(switch_block.node_sprite,"modulate",Color(Color.WHITE, op),dur_open)

# only works with one body
func check_intersects() -> bool:
	var areas := get_overlapping_areas()
	var value := areas.size() > 0 && areas[0] is Bokoblock
		
	is_body_intersecting = value
	
	if is_body_intersecting:
		modulate = Color(Color.WHITE, 0.75)
		body_intersecting = (areas[0] as Bokoblock).parent_bokobody
		
		body_intersecting.is_on_top_switch_block = true
		# Holds till the intersecting body exits
		GameLogic.bokobody_stopped.connect(_on_intersecting_bokobody_stopped)
	
	return value


func _on_intersecting_bokobody_stopped(is_body: Bokobody) -> void:
	# Checks if intersecting body has exited
	if is_body == body_intersecting && get_overlapping_areas().is_empty():
		modulate = Color(Color.WHITE, 1.0)
		
		is_body_intersecting = false
		
		body_intersecting.is_on_top_switch_block = false
		body_intersecting = null
		
		GameLogic.bokobody_stopped.disconnect(_on_intersecting_bokobody_stopped)
