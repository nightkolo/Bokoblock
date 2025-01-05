## Level code.
extends Node2D
class_name Stage

@export var auto_assign_ids: bool = true
@export var stage_id: int = -1:
	get:
		return stage_id
	set(value):
		GameMgr.current_stage_id = value
		stage_id = value
@export var world_id: int = -1:
	get:
		return world_id
	set(value):
		GameMgr.current_world_id = value
		world_id = value
@export_group("Miscellanous")
@export var show_dev_ui: bool = true

var _dev_ui: PackedScene = preload("res://interface/runtime/misc/dev_ui.tscn")


func _ready() -> void:
	GameMgr.current_stage = self

	if auto_assign_ids:
		var num := self.scene_file_path.to_int()

		stage_id = num
		world_id = floori(num / 10.0) + 1
	
	if show_dev_ui:
		var dev_ui := _dev_ui.instantiate()
		dev_ui.name = "DevUI"
		add_child(dev_ui)
