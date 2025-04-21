## Opened by [ButtonObj]
##
## Under Construction
extends Area2D
class_name SwitchBlocks

# TODO: Has issues when interacting with two Buttons of same BokoColor of Switch Block

signal has_opened(is_open: bool)

@export var switch_type_decorator: GameUtil.SwitchTypeDecorator

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


func _ready() -> void:
	_setup_node()
	
	has_opened.connect(func(p_is_open: bool):
		if p_is_open:
			anim_open()
		else:
			anim_close()
		)
	
	# Possibly problematic code
	#GameLogic.button_held.connect(func(is_color: GameUtil.BokoColor):
		#if is_color == switch_type_decorator:
			#open(true)
		#)
		#
	#GameLogic.button_released.connect(func(is_color: GameUtil.BokoColor):
		#if is_color == switch_type_decorator:
			#open(false)
		#)


func _setup_node():
	for switch_block: SwitchBlock in child_switch_blocks:
		
		match switch_type_decorator:
			pass
			
		#if switch_block.sprite:
			#switch_block.sprite.self_modulate = GameUtil.set_boko_color(switch_type_decorator)


func open(open_or_close: bool = !is_open) -> void:
	if open_or_close != is_open:
		is_open = open_or_close
		
		for switch_block: SwitchBlock in child_switch_blocks:
			switch_block.set_deferred("disabled", is_open)
		
		await GameMgr.process_waittime()
		
		if is_open == false:
			check_intersects()


# only works with one body
func check_intersects() -> bool:
	var areas := get_overlapping_areas()
	var value := areas.size() == 1 && areas[0] is Bokoblock
		
	is_body_intersecting = value
	
	if is_body_intersecting:
		body_intersecting = (areas[0] as Bokoblock).parent_bokobody
		
		body_intersecting.is_on_top_switch_block = true
		
		# Holds till the intersecting body exits
		GameLogic.bokobody_stopped.connect(_on_intersecting_bokobody_stopped)
	
	return value


func _on_intersecting_bokobody_stopped(is_body: Bokobody):
	# Checks if intersecting body has exited
	if is_body == body_intersecting && get_overlapping_areas().is_empty():
		is_body_intersecting = false
		
		body_intersecting.is_on_top_switch_block = false
		body_intersecting = null
		
		GameLogic.bokobody_stopped.disconnect(_on_intersecting_bokobody_stopped)

	
func anim_open() -> void:
	for switch_block: SwitchBlock in child_switch_blocks:
		if switch_block.node_sprite:
			switch_block.node_sprite.modulate = Color(Color.WHITE, 0.5)
	
	
func anim_close() -> void:
	for switch_block: SwitchBlock in child_switch_blocks:
		if switch_block.node_sprite:
			switch_block.node_sprite.modulate = Color(Color.WHITE, 1.0)
