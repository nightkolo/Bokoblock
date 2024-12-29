extends Node2D
class_name Level

@export var show_dev_ui: bool = true ## @experimental

#var _dev_ui: PackedScene = preload("res://menus/runtime/ui/misc/dev_ui.tscn")


func _ready() -> void:
	GameLogic.current_level = self
