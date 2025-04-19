## Under construction
extends Area2D
class_name ButtonObj

signal button_held(is_held: bool) ## @experimental

@export var switch_blocks_to_activate: GameUtil.BokoColor
@export_group("Nodes to Assign")
@export var node_sprite: Node2D
@export var sprite: Sprite2D

var is_held: bool = false:
	set(value):
		if value != is_held:
			# TODO: Remove the global handling, and make it local for less complexity and bug potential
			if value:
				GameLogic.button_held.emit(switch_blocks_to_activate)
			else:
				GameLogic.button_released.emit(switch_blocks_to_activate)
		is_held = value


func _ready() -> void:
	_setup_node()
	
	GameLogic.bokobodies_stopped.connect(check_state)
	

func _setup_node():
	if sprite:
		sprite.self_modulate = GameUtil.set_boko_color(switch_blocks_to_activate)


func check_state() -> bool:
	var areas: Array[Area2D] = get_overlapping_areas()
	var value := areas.size() == 1 && areas[0] is Bokoblock

	is_held = value
	
	return value
