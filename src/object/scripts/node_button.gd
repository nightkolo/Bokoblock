## Under construction
extends Area2D
class_name ButtonObj

# TODO: Not sure if it should be global or local..

signal button_held(is_held: bool)

@export var switch_blockss_to_trigger: Array[SwitchBlocks]
@export var switch_type_decorator: GameUtil.SwitchTypeDecorator
@export_group("Nodes to Assign")
@export var node_sprites: Node2D
@export var sprite_head: Sprite2D
@export var sprite_base: Sprite2D
@export_group("Assets")
@export var texture_cross: Texture = preload("res://assets/objects/button-v02-head-cross.png")
@export var texture_square: Texture = preload("res://assets/objects/button-v02-head-square.png")

#@onready var sprite_base: Sprite2D = $Node2D/SpriteBase
#@onready var sprite_top: Sprite2D = $Node2D/SpriteTop
#@onready var sprite_height: Sprite2D = $Node2D/SpriteHeight

#@onready var anim: AnimationPlayer = $Anim

var is_held: bool = false:
	set(value):
		if value != is_held:
			button_held.emit(value)
			for switch_blocks: SwitchBlocks in switch_blockss_to_trigger:
				switch_blocks.open(value)
			#if value:
				#GameLogic.button_held.emit(switch_type_decorator)
			#else:
				#GameLogic.button_released.emit(switch_type_decorator)
		is_held = value


func _ready() -> void:
	_setup_node()
	
	GameLogic.bokobodies_stopped.connect(check_state)
	
	button_held.connect(func(p_is_held: bool):
		if p_is_held:
			anim_button_held()
		else:
			anim_button_rest()
		)
	

func _setup_node():
	anim_idle()
	
	# TODO: should be collision_layer = 8 (Object) but Godot is acting strange
	
	collision_layer = 4
	collision_mask = 15
	
	match switch_type_decorator:
		
		GameUtil.SwitchTypeDecorator.Cross:
			sprite_head.texture = texture_cross
			
		GameUtil.SwitchTypeDecorator.Square:
			sprite_head.texture = texture_square


func check_state() -> bool:
	var areas: Array[Area2D] = get_overlapping_areas()
	var value := areas.size() == 1 && areas[0] is Bokoblock

	is_held = value
	
	return value


func anim_idle() -> void:
	var dur := 0.8
	var dur_pulse := 1.2
	var pulse_to := 1.35
	
	var tween_spin := create_tween().set_loops()
	tween_spin.tween_property(sprite_head,"rotation",PI/4.0,dur).as_relative()
	
	var tween_pulse := create_tween().set_loops()
	tween_pulse.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_pulse.tween_property(sprite_head,"self_modulate",Color(Color.WHITE*pulse_to),dur_pulse)
	tween_pulse.tween_property(sprite_head,"self_modulate",Color(Color.WHITE),dur_pulse)


#var tween_button: Tween


func anim_button_held() -> void:
	pass
	
	#if tween_button:
		#tween_button.kill()
		#
	#tween_button = create_tween().set_parallel(true)
	#tween_button.tween_property(sprite_top, "scale", Vector2(1.5,0.75), 0.4)
	#tween_button.tween_property(sprite_height, "scale", Vector2(1.5,0.75), 0.4)
	
	
func anim_button_rest() -> void:
	pass
	
	#if tween_button:
		#tween_button.kill()
		#
	#tween_button = create_tween().set_parallel(true)
	#tween_button.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#
	#sprite_top.scale = Vector2(2.0,0.5)
	#sprite_height.scale = Vector2(2.0,0.5)
	#
	#tween_button.tween_property(sprite_top, "scale", Vector2.ONE, 0.4)
	#tween_button.tween_property(sprite_height, "scale", Vector2.ONE, 0.4)
	
