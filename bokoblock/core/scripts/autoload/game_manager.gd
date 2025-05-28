## Runtime actor model
extends Node

signal menu_entered(entered: Menus)
signal game_just_ended()
signal game_end()
signal game_reset()
signal game_data_saved()
signal game_data_loaded()

enum Menus {
	MENUS = 0,
	PAUSE = 1,
	CHECKERBOARD_COMPLETE = 2,
	START = 3,
	RUNTIME = 99
}

var current_menu: Menus = Menus.START
var current_ui_handler: GameplayUI
var current_board: Board
var current_board_id: int = -1
var current_checkerboard_id: int = -1

var is_game_manager_resetting: bool = false ## @experimental
var is_sfx_muted: bool = false
var is_music_muted: bool = false

var saver_loader: SaverLoader = SaverLoader.new()

const ON_NEWGROUNDS_MIRROR = true


func _ready() -> void:
	add_child(saver_loader)
	
	load_game_data() 
	
	game_end.connect(stage_complete)
	
	menu_entered.connect(func(entered: Menus):
		current_menu = entered
		)
	
	game_reset.connect(func():
		_reset_game_manager()
		get_tree().reload_current_scene()
		)
	
	game_just_ended.connect(func():
		# Awaits complete animation
		await get_tree().create_timer(GameUtil.stage_complete_anim_waittime).timeout
		game_end.emit()
	)


func stage_complete() -> void:
	if current_board_id / 10.0 == 1.0:
		open_checkerboard_complete_screen()
	else:
		goto_next_stage()


func open_checkerboard_complete_screen() -> void:
	if current_ui_handler:
		current_ui_handler.the_checkerboard_has_been_checkered()


## Goes to next stage.
## [br][br]Enabling [param force_progression] bypasses [member Board.stage_progression] and forces progression.
func goto_next_stage(force_progression: bool = false) -> void:
	if current_board:
		if !current_board.stage_progression && !force_progression:
			print("current_board.stage_progression is false, progression stopped.")
			return
	
	_reset_game_manager()
	GameLogic.self_destruct()
	
	var next_lvl_id := current_board_id + 1
	var next_lvl_path := GameUtil.STAGE_FILE_BEGIN + str(next_lvl_id) + GameUtil.STAGE_FILE_END
	
	if next_lvl_id <= GameUtil.NUMBER_OF_BOARDS: 
		Trans.slide_to_next_stage(next_lvl_path)


func goto_next_checkerboard() -> void:
	goto_next_stage(true)
	
	await get_tree().create_timer(1.5).timeout
	Audio.set_music()


func goto_prev_stage() -> void:
	if current_board:
		return
	
	_reset_game_manager()
	GameLogic.self_destruct()
	
	var next_lvl_id := current_board_id - 1
	var next_lvl_path := GameUtil.STAGE_FILE_BEGIN + str(next_lvl_id) + GameUtil.STAGE_FILE_END
	
	if next_lvl_id <= GameUtil.NUMBER_OF_BOARDS: 
		get_tree().change_scene_to_file(next_lvl_path)


func reset_game() -> void:
	game_reset.emit()


func reset_game_data() -> void:
	saver_loader.new_game()


func save_game_data() -> void:
	saver_loader.save_game()


func load_game_data() -> void:
	saver_loader.load_game()


func process_waittime(wait: float = 0.05) -> void: ## @deprecated
	await get_tree().create_timer(wait).timeout


func self_destruct() -> void: ## @experimental
	_reset_game_manager()
	

func _reset_game_manager() -> void:
	pass
	#if !is_game_manager_resetting:
		#is_game_manager_resetting = true
		#
		#await get_tree().create_timer(0.1).timeout
		#is_game_manager_resetting = false
