## Level code.
extends Node2D
class_name Board 

@export var auto_assign_ids: bool = true
@export var board_id: int = -1:
	get:
		return board_id
	set(value):
		GameMgr.current_board_id = value
		board_id = value
@export var checkerboard_id: int = -1:
	get:
		return checkerboard_id
	set(value):
		GameMgr.current_checkerboard_id = value
		checkerboard_id = value
@export_group("Miscellanous")
@export var show_dev_ui: bool = false
@export var custom_block_match: int = -1 ## @experimental
@export_category("Game")
@export var stage_progression: bool = true
@export var save_stats: bool = false ## @experimental
@export var win_condition: GameLogic.WinCondition

var saver_loader: SaverLoader

var _dev_ui: PackedScene = preload("res://interface/runtime/miscellanous/dev_ui.tscn")
var _moves_counted: int = 0:
	get:
		return _moves_counted
	set(value):
		_moves_counted = mini(999, value)


func _ready() -> void:
	GameMgr.current_board = self
	GameMgr.menu_entered.emit(GameMgr.Menus.RUNTIME)
	GameLogic.set_win_condition(win_condition)
	
	if auto_assign_ids:
		var num := self.scene_file_path.to_int()

		board_id = num
		checkerboard_id = ceili(num / 10.0)
	
	if show_dev_ui:
		var dev_ui := _dev_ui.instantiate()
		dev_ui.name = "DevUI"
		add_child(dev_ui)
	
	if save_stats:
		GameMgr.game_just_ended.connect(store_stats)
		
		var SL: SaverLoader = SaverLoader.new()
		add_child(SL)
		saver_loader = SL
	
	GameLogic.state_checked.connect(func(have_moved: bool):
		if have_moved:
			_moves_counted += 1
		)

	#GameMgr.open_checkerboard_complete_screen()


func store_stats() -> void:
	if !save_stats:
		return
		
	if saver_loader == null:
		push_warning("Cannot save data. saver_loader not assigned.")
		return
	
	var id: String = str(board_id)
	
	if !GameData.runtime_data.has(id):
		push_error("Cannot save data. Key %s not found in GameData.runtime_data." % id)
		return
	
	if GameData.runtime_data[id]["completed"] == false:
		GameData.runtime_data[id]["completed"] = true
	
	if _moves_counted < GameData.runtime_data[id]["move_count"]: # deprecated
		GameData.runtime_data[id]["move_count"] = _moves_counted
		
	#saver_loader.save_game()
