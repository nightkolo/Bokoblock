## Level code.
extends Node2D
class_name Stage

#signal move_counter_threshold_passed(has_passed: bool)

@export var auto_assign_ids: bool = true
@export var stage_id: int = -1:
	get:
		return stage_id
	set(value):
		GameMgr.current_stage_id = value
		stage_id = value
@export var checkerboard_id: int = -1:
	get:
		return checkerboard_id
	set(value):
		GameMgr.current_checkerboard_id = value
		checkerboard_id = value
@export_group("Miscellanous")
@export var show_dev_ui: bool = false
@export var custom_block_match: int = -1 ## @experimental
@export var stage_progression: bool = true
@export_category("Game")
@export var save_stats: bool = true
@export var win_condition: GameLogic.WinCondition
#@export var allow_undoing: bool = true:
	#set(value):
		#if value == false:
			#for body: Bokobody in GameMgr.current_bodies:
				#body.no_undo = false
		#allow_undoing = value
#@export var moves_threshold: int = 25
#@export var move_counter: MoveCounter

var saver_loader: SaverLoader
var is_yellow_starred: bool = true ## @deprecated
#var moves_counted: int
var improved_stats: bool = false ## @deprecated

var _world_1: PackedScene = preload("res://world_1.tscn")
var _dev_ui: PackedScene = preload("res://interface/runtime/misc/dev_ui.tscn")
var _moves_counted: int = 0:
	get:
		return _moves_counted
	set(value):
		#var counted := mini(999, maxi(0, value))
		#var yellowed := counted <= moves_threshold
		
		#_moves_counted = counted
		_moves_counted = mini(999, value)
		#moves_counted = moves_threshold - counted
		
		#print(_moves_counted)
		
		#if move_counter:
			#move_counter.label.text = str(absi(moves_counted))
			#move_counter.label.pivot_offset = move_counter.label.size/2.0
			#move_counter.anim_increment()
		
		#if !yellowed && is_yellow_starred:
			#move_counter_threshold_passed.emit(true)
			#is_yellow_starred = yellowed
		#elif yellowed && !is_yellow_starred:
			#move_counter_threshold_passed.emit(false)
			#is_yellow_starred = yellowed


func _ready() -> void:
	GameMgr.current_stage = self
	GameMgr.game_entered.emit(true)
	GameLogic.set_win_condition(win_condition)
	if auto_assign_ids:
		var num := self.scene_file_path.to_int()

		stage_id = num
		checkerboard_id = ceili(num / 10.0)
	#else:
		#if stage_id == 1 && checkerboard_id == 1:
			#var scene = _world_1.instantiate()
			#
			#print(scene)
			#
			#add_child(scene)
			
	
	if show_dev_ui:
		var dev_ui := _dev_ui.instantiate()
		dev_ui.name = "DevUI"
		add_child(dev_ui)
	
	if save_stats:
		GameMgr.game_just_ended.connect(store_stats)
		
		var SL: SaverLoader = SaverLoader.new()
		add_child(SL)
		saver_loader = SL
	
	#if move_counter:
		#move_counter.label.text = str(moves_threshold)
	#
	#moves_counted = moves_threshold
	
	#move_counter_threshold_passed.connect(func(has_passed: bool):
		#if move_counter:
			#if has_passed:
				#move_counter.anim_purple_starred()
			#else:
				#move_counter.anim_yellow_starred()
		#)
	
	GameLogic.state_checked.connect(func(have_moved: bool):
		if have_moved:
			_moves_counted += 1
		)
		
	#PlayerInput.input_undo.connect(func():
		#if allow_undoing:
			#_moves_counted -= 1
		#)
		
	#await get_tree().create_timer(0.1).timeout
	#if allow_undoing == false:
		#for body: Bokobody in GameMgr.current_bodies:
			#body.no_undo = !allow_undoing


func store_stats() -> void:
	if !save_stats:
		return
		
	if saver_loader == null:
		push_warning("Cannot save data. saver_loader not assigned.")
		return
	
	var id: String = str(stage_id)
	
	if !GameData.runtime_data.has(id):
		push_error("Cannot save data. Key %s not found in GameData.runtime_data." % id)
		return
	
	if GameData.runtime_data[id]["completed"] == false:
		GameData.runtime_data[id]["completed"] = true
	
	if GameData.runtime_data[id]["starred"] == false:
		GameData.runtime_data[id]["starred"] = is_yellow_starred
		
	if _moves_counted < GameData.runtime_data[id]["move_count"]:
		# if GameData.runtime_data[id]["move_count"] != 999:
		improved_stats = true
		
		GameData.runtime_data[id]["move_count"] = _moves_counted
		
	#saver_loader.save_game()


func get_real_moves_counted() -> int:
	return _moves_counted
