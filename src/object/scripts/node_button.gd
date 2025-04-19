## Under construction
extends Area2D
class_name ButtonObj

signal button_held(is_held: bool) ## @experimental

@export var switch_blocks_to_activate: GameUtil.BokoColor
@export_group("Nodes to Assign")
@export var node_sprite: Node2D
@export var sprite: Sprite2D

@onready var sprite_base: Sprite2D = $Node2D/SpriteBase
@onready var sprite_top: Sprite2D = $Node2D/SpriteTop
@onready var sprite_height: Sprite2D = $Node2D/SpriteHeight

@onready var anim: AnimationPlayer = $Anim

var is_held: bool = false:
	set(value):
		if value != is_held:
			button_held.emit(value)
			# TODO: Remove the global handling, and make it local for less complexity and bug potential
			if value:
				GameLogic.button_held.emit(switch_blocks_to_activate)
			else:
				GameLogic.button_released.emit(switch_blocks_to_activate)
		is_held = value


func _ready() -> void:
	_setup_node()
	
	button_held.connect(func(is_held: bool):
		if is_held:
			anim_button_held()
		else:
			anim_button_rest()
		)
	
	GameLogic.bokobodies_stopped.connect(check_state)
	

func _setup_node():
	# TODO: should be collision_layer = 8 (Object) but Godot is acting strange
	collision_layer = 4
	collision_mask = 15
	
	
	node_sprite.modulate = GameUtil.set_boko_color(switch_blocks_to_activate)
	

func check_state() -> bool:
	var areas: Array[Area2D] = get_overlapping_areas()
	var value := areas.size() == 1 && areas[0] is Bokoblock

	is_held = value
	
	return value


var tween_button: Tween


func anim_button_held() -> void:
	if tween_button:
		tween_button.kill()
		
	tween_button = create_tween().set_parallel(true)
	tween_button.tween_property(sprite_top, "scale", Vector2(1.5,0.75), 0.4)
	tween_button.tween_property(sprite_height, "scale", Vector2(1.5,0.75), 0.4)
	
	
func anim_button_rest() -> void:
	if tween_button:
		tween_button.kill()
		
	tween_button = create_tween().set_parallel(true)
	tween_button.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	sprite_top.scale = Vector2(2.0,0.5)
	sprite_height.scale = Vector2(2.0,0.5)
	
	tween_button.tween_property(sprite_top, "scale", Vector2.ONE, 0.4)
	tween_button.tween_property(sprite_height, "scale", Vector2.ONE, 0.4)
	
