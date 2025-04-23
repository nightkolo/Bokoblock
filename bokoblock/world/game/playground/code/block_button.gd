# @experimental
extends Button

@onready var block: Bokoblock = get_parent()


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	#print(str(block) + " is pressed!")
	
	match GameMgr.get_card_type():
		
		TestCardUI.CardType.Remove:
			block.get_out()
		
		TestCardUI.CardType.Recolor:
			block.change_bokocolor_of_dad()
			
		TestCardUI.CardType.Misc:
			block.change_bokocolor()
