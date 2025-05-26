extends Node2D
class_name Intro

@onready var character_chibi_boko: CharacterChibiBoko = $CharacterChibiBoko


func _ready() -> void:
	anim_loop_test()


func anim_loop_test() -> void:
	character_chibi_boko.pose_happy()
	
	await get_tree().create_timer(2.5).timeout
	
	character_chibi_boko.pose_asleep()

	await get_tree().create_timer(2.5).timeout
	
	character_chibi_boko.pose_woke()

	await get_tree().create_timer(2.5).timeout
	
	character_chibi_boko.pose_neutral()

	await get_tree().create_timer(2.5).timeout
	
	anim_loop_test()
