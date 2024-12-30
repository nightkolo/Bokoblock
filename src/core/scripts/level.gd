extends Node2D
class_name Level

@export var auto_assign_id: bool = true
@export var level_id: int = -1
@export_group("Miscellanous")
@export var show_dev_ui: bool = true

var _dev_ui: PackedScene = preload("res://interface/runtime/misc/dev_ui.tscn")


func _ready() -> void:
	GameMgr.current_level = self

	if auto_assign_id:
		level_id = self.scene_file_path.to_int()
	
	GameMgr.current_level_id = level_id
	
	if show_dev_ui:
		var dev_ui := _dev_ui.instantiate()
		dev_ui.name = "DevUI"
		add_child(dev_ui)
