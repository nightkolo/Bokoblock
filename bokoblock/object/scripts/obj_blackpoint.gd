## Preferably use [url]res://object/objects/obj_blackpoint.tscn[\url].
extends Area2D
class_name Blackpoint

@onready var sprite_shadow: Sprite2D = $Sprites/Shadow
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var audio_entered: AudioStreamPlayer2D = $Aud/Enter
@onready var audio_exited: AudioStreamPlayer2D = $Aud/Exit

var is_landed_on: bool:
	get:
		return is_landed_on
	set(value):
		if value != is_landed_on:
			if value:
				audio_entered.play()
			else:
				audio_exited.play()
		
		is_landed_on = value


func _ready() -> void:
	anim_idle()
	anim_shadow()
	
	GameLogic.bodies_stopped.connect(check_for_prey)


func check_for_prey() -> void:
	var areas: Array[Area2D] = get_overlapping_areas()

	is_landed_on = areas.size() == 1 && areas[0] is Bokoblock
	
	if is_landed_on:
		GameLogic.body_entered_blackpoint()


func anim_shadow() -> void:
	sprite_shadow.scale = Vector2.ONE / 4.0
	
	var tween := create_tween().set_loops()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite_shadow, "scale", Vector2.ONE / 2.0, 0.4).set_delay(1.6)
	tween.tween_property(sprite_shadow, "scale", Vector2.ONE / 4.0, 1.4).set_delay(0.4)


func anim_idle() -> void:
	await get_tree().create_timer(0.25).timeout
	anim.play(&"idle")
