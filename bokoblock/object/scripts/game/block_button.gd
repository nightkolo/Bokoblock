# @experimental
class_name BokoblockClickable
extends Button

@onready var block: Bokoblock = get_parent()


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	if block is Bokoblock:
		if block.animator:
			block.animator.anim_poke()
			
			if GameData.medal_data["poke_the_block"] == false: 
				GameMgr.current_ui_handler.a_medal_has_been_unlocked()
			
				MedalMgr.unlock_a_medal("poke_the_block")
