# @experimental
class_name BokoblockClickable
extends Button

@onready var block: Bokoblock = get_parent()

var color_scale: Array[int] = [0, 1, 2, 3, 1]

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	#print(str(block) + " is pressed!")
	
	block.animator.anim_poke()
	
	#match GameMgr.get_card_type():
		#
		#TestCardUI.CardType.Remove:
			#($Remove as AudioStreamPlayer2D).play()
			#block.get_out()
		#
		#TestCardUI.CardType.Recolor:
			#($Recolor as AudioStreamPlayer2D).play()
			#block.change_bokocolor_of_dad()
			#
		#TestCardUI.CardType.Misc:
			#($Recolor as AudioStreamPlayer2D).play()
			#block.change_bokocolor()
