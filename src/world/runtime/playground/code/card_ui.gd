## @experimental
extends Node2D
class_name TestCardUI

signal card_type_set(c: CardType)

## @experimental
enum CardType {
	Remove = 0,
	Recolor = 1,
	Misc = 2
}

var current_card_type: CardType


func _ready() -> void:
	GameMgr.current_card_ui = self
	
	
func set_card_type(is_type: CardType) -> void:
	current_card_type = is_type
	card_type_set.emit(is_type)
