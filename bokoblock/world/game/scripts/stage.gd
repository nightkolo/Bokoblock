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
@export var show_dev_ui: bool = false
@export var custom_block_match: int = -1 ## @experimental
@export var stage_progression: bool = true
@export_category("Game")
@export var win_condition: GameLogic.WinCondition
@export var moves_threshold: int = 10

var moves_counted: int = 0

var _dev_ui: PackedScene = preload("res://interface/runtime/misc/dev_ui.tscn")


func _ready() -> void:
	GameMgr.current_stage = self
	GameMgr.game_entered.emit(true)
	GameLogic.set_win_condition(win_condition)
	
	
	
	if auto_assign_ids:
		var num := self.scene_file_path.to_int()

		stage_id = num
		world_id = ceili(num / 10.0)
	
	if show_dev_ui:
		var dev_ui := _dev_ui.instantiate()
		dev_ui.name = "DevUI"
		add_child(dev_ui)
