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
			
			MedalMgr.unlocked("Poke the Blocks")
			#MedalMgr.unlock_a_medal()
