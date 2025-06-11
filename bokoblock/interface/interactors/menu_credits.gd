extends MainMenu
class_name CreditsScreen

@onready var back_btn: Button = %BackButton


func _ready() -> void:
	back_btn.grab_focus()
	
	is_showing.connect(func():
		if GameMgr.current_menu != GameMgr.Menus.CREDITS:
			GameMgr.menu_entered.emit(GameMgr.Menus.CREDITS)
			
		back_btn.grab_focus()
		)
	
	back_btn.pressed.connect(func():
		GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
		
		back_button_pressed.emit()
		)
