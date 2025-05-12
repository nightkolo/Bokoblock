## Level code.
extends Node2D
class_name Stage

signal move_counter_threshold_passed(has_passed: bool)

@export var auto_assign_ids: bool = true
@export var stage_id: int = -1:
	get:
		return stage_id
	set(value):
		GameMgr.current_stage_id = value
		stage_id = value
@export var world_id: int = -1: # TODO: change to checkerboard_id
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

var is_yellow_starred: bool = true
var moves_counted: int

var _dev_ui: PackedScene = preload("res://interface/runtime/misc/dev_ui.tscn")
var _moves_counted: int = 0:
	get:
		return _moves_counted
	set(value):
		var counted := maxi(0, value)
		var yellowed := counted <= moves_threshold
		
		_moves_counted = counted
		moves_counted = moves_threshold - counted
		
		if !yellowed && is_yellow_starred:
			move_counter_threshold_passed.emit(true)
			is_yellow_starred = yellowed
		elif yellowed && !is_yellow_starred:
			move_counter_threshold_passed.emit(false)
			is_yellow_starred = yellowed


func _ready() -> void:
	GameMgr.current_stage = self
	GameMgr.game_entered.emit(true)
	GameLogic.set_win_condition(win_condition)
	
	move_counter_threshold_passed.connect(func(_has_passed: bool):
		pass
		)
	
	GameLogic.state_checked.connect(func():
		if GameLogic.we_have_made_a_move:
			_moves_counted += 1
		)
		
	PlayerInput.input_undo.connect(func():
		_moves_counted -= 1
		)
		
	moves_counted = moves_threshold
	
	if auto_assign_ids:
		var num := self.scene_file_path.to_int()

		stage_id = num
		world_id = ceili(num / 10.0)
	
	if show_dev_ui:
		var dev_ui := _dev_ui.instantiate()
		dev_ui.name = "DevUI"
		add_child(dev_ui)


func get_real_moves_counted() -> int:
	return _moves_counted
