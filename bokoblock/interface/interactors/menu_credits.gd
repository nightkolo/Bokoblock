extends MainMenu
class_name CreditsScreen

@onready var back_btn: Button = %BackButton
@onready var chibi_boko: CharacterChibiBoko = $Main2/CharacterChibiBoko
@onready var messages: Node2D = $Main2/Messages

@onready var kolo: Label = %Me ## @experimental


func _ready() -> void:
	back_btn.grab_focus()
	
	is_showing.connect(func():
		for node: Node in messages.get_children():
			node.visible = false
		
		chibi_boko.pose_happy()
		messages.get_children()[0].visible = true

		GameMgr.menu_entered.emit(GameMgr.Menus.CREDITS)
			
		#if GameMgr.game_has_ended:
			#chibi_boko.pose_happy()
			#messages.get_children()[0].visible = true
			#
			#GameMgr.game_has_ended = false
		#else:
			#GameMgr.menu_entered.emit(GameMgr.Menus.CREDITS)
			#
			#open_random_message()
		
		back_btn.grab_focus()
		)
	
	back_btn.pressed.connect(func():
		GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
		
		back_button_pressed.emit()
		)


func open_random_message() -> void: ## @experimental
	chibi_boko.pose_neutral()
	
	var count := messages.get_child_count()
	var index := randi_range(1 , count - 1)
	
	messages.get_children()[index].visible = true
