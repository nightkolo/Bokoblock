# @experimental
class_name BokoblockClickable
extends Button

@onready var block: Bokoblock = get_parent()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("poke_block"):
		_on_pressed()


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	if block is Bokoblock:
		if block.animator:
			block.animator.anim_poke()
			
			if GameData.medal_data.has("poke"):
				if GameData.medal_data["poke"] == false: 
					match GameMgr.menu_id:
						
						GameMgr.Menus.RUNTIME:
							if GameMgr.current_ui_handler:
								GameMgr.current_ui_handler.a_medal_has_been_unlocked()
						
						GameMgr.Menus.MENUS, GameMgr.Menus.CREDITS:
							if GameMgr.current_medal_notifier:
								GameMgr.current_medal_notifier.anim_medal_unlocked()
					
			await MedalMgr.unlock_a_medal("poke", NewgroundsIds.MedalId.CanYouPokeTheBlocks)
