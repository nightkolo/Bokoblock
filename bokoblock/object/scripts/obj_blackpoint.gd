## Under construction
##
## Preferably use [url]res://object/objects/obj_blackpoint.tscn[\url].
extends Area2D
class_name Blackpoint

@onready var sprite_shadow: Sprite2D = $Sprites/Shadow
@onready var anim: AnimationPlayer = $AnimationPlayer

var is_landed_on: bool


func _ready() -> void:
	GameLogic.blackpoint = true
	
	anim_idle()
	anim_shadow()
	
	GameLogic.bodies_stopped.connect(check_satisfaction)


func check_satisfaction() -> void:
	var areas: Array[Area2D] = get_overlapping_areas()

	is_landed_on = areas.size() == 1 && areas[0] is Bokoblock
	
	if is_landed_on:
		GameLogic.body_entered_blackpoint()


func anim_shadow():
	if sprite_shadow:
		sprite_shadow.scale = Vector2.ONE / 4.0
		
		var tween := create_tween().set_loops()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(sprite_shadow, "scale", Vector2.ONE / 2.0, 0.4).set_delay(1.6)
		tween.tween_property(sprite_shadow, "scale", Vector2.ONE / 4.0, 1.4).set_delay(0.4)


func anim_idle() -> void:
	await get_tree().create_timer(0.25).timeout
	anim.play(&"idle")
	#var time := dur / 8.0
	#var mag := 5.0
	
	#if node_sprites:
		## I really don't want to use animationplayer...
		#
		#node_sprites.rotation_degrees = mag * 2.0
		#
		#await get_tree().create_timer(time).timeout
		#
		#node_sprites.rotation_degrees = mag * 1.0
		#
		#await get_tree().create_timer(time).timeout
		#
		#node_sprites.rotation_degrees = mag * 0.0
		#
		#await get_tree().create_timer(time).timeout
		#
		#node_sprites.rotation_degrees = mag * -1.0
		#
		#await get_tree().create_timer(time).timeout
		#
		#node_sprites.rotation_degrees = mag * -2.0
		#
		#await get_tree().create_timer(time).timeout
		#
		#node_sprites.rotation_degrees = mag * -1.0
		#
		#await get_tree().create_timer(time).timeout
		#
		#node_sprites.rotation_degrees = mag * 0.0
		#
		#await get_tree().create_timer(time).timeout 
		#
		#node_sprites.rotation_degrees = mag * 1.0
		#
		#await get_tree().create_timer(time).timeout
		#
		#anim_idle()
