## @experimental: Under Construction
extends Area2D
class_name SwitchBlocks

# TODO: Has issues when interacting with two Buttons of same BokoColor of Switch Block

signal has_opened(is_open: bool)

@export var my_color: GameUtil.BokoColor

@onready var child_switch_blocks: Array[Node] = get_children()

var is_open: bool:
	get:
		return is_open
	set(value):
		if value != is_open:
			has_opened.emit(value)
		is_open = value


func _ready() -> void:
	_setup_node()
	
	has_opened.connect(func(is_open: bool):
		if is_open:
			anim_open()
		else:
			anim_close()
		)
	
	# problematic code
	GameLogic.button_held.connect(func(is_color: GameUtil.BokoColor):
		if is_color == my_color:
			open(true)
		)
		
	GameLogic.button_released.connect(func(is_color: GameUtil.BokoColor):
		if is_color == my_color:
			open(false)
		)


func _setup_node():
	for switch_block: SwitchBlock in child_switch_blocks:
		if switch_block.sprite:
			switch_block.sprite.self_modulate = GameUtil.set_boko_color(my_color)


func open(open_or_close: bool) -> void:
	if open_or_close != is_open:
		is_open = open_or_close
		
		# TODO: issue when body stands on switch block when it opens
		
		for switch_block: SwitchBlock in child_switch_blocks:
			switch_block.set_deferred("disabled", is_open)
	
	
func anim_open() -> void:
	for switch_block: SwitchBlock in child_switch_blocks:
		if switch_block.node_sprite:
			switch_block.node_sprite.modulate = Color(Color.WHITE, 0.5)
	
	
func anim_close() -> void:
	for switch_block: SwitchBlock in child_switch_blocks:
		if switch_block.node_sprite:
			switch_block.node_sprite.modulate = Color(Color.WHITE, 1.0)
