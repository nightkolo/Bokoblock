extends MainMenu
class_name CreditsScreen

@onready var back_btn: Button = %BackButton


func _ready() -> void:
	back_btn.grab_focus()
	
	back_btn.pressed.connect(func():
		back_button_pressed.emit()
		)
