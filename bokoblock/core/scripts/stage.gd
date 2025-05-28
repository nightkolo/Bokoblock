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
@export var save_stats: bool = true
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
	@warning_ignore("static_called_on_instance")
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


func store_stats() -> void:
	if !save_stats:
		return
		
	if saver_loader == null:
		push_warning("Cannot save data. saver_loader not assigned.")
		return
	
	var board_num: String = str(board_id)
	var checkerboard_num: String = "10" + str(checkerboard_id)
	
	if !GameData.runtime_data.has(board_num):
		push_error("Cannot save data. Key %s not found in GameData.runtime_data." % board_num)
		return
	
	if !GameData.runtime_data.has(checkerboard_num):
		push_error("Cannot save data. Key %s not found in GameData.runtime_data." % checkerboard_num)
		return
	
	if _moves_counted < GameData.runtime_data[board_num]["move_count"]:
		GameData.runtime_data[board_num]["move_count"] = _moves_counted
	
	if GameData.runtime_data[board_num]["completed"] == false:
		GameData.runtime_data[board_num]["completed"] = true
	
	if GameData.runtime_data[checkerboard_num]["completed"] == false:
		GameData.runtime_data[checkerboard_num]["completed"] = _check_cb_progression(checkerboard_id)
	
	saver_loader.save_game()


func _check_cb_progression(cb: int) -> bool:
	var begin: int = 1 + ((	cb - 1) * 10)
	var end: int = 11 + ((cb - 1) * 10)
	
	print(begin, "  ", end)
	
	var completed: int = 0
	
	for i: int in range(begin, end):
		if !GameData.runtime_data.has(str(i)):
			push_warning("Cannot read data for _check_cb_progression. Key %s not found in GameData.runtime_data." % str(i))
			return false
			
		if GameData.runtime_data[str(i)]["completed"] == true:
			completed += 1
	
	return completed == GameUtil.NUMBER_OF_BOARDS_PER_CHECKERBOARD
