## Runtime actor model
extends Node

signal menu_entered(entered: Menus)
signal game_pause_toggled(is_paused: bool)
signal game_just_ended()
signal game_end()
signal game_reset()
signal game_data_saved()
signal game_data_loaded()
signal game_medals_data_saved()
signal game_medals_data_loaded()

enum Menus {
	## Board select and title screens are MENUS = 0
	MENUS = 0,
	PAUSE = 1,
	CHECKERBOARD_COMPLETE = 2,
	START = 3,
	CREDITS = 4,
	RUNTIME = 99
}

var current_ui_handler: GameplayUI # Null check needed
var current_menu: MainMenusUI # Null check needed
var current_board: Board # Null check needed
var current_medal_notifier: MedalUnlockedPopup # Null check needed
var menu_id: Menus = Menus.START
var board_id: int = -1
var checkerboard_id: int = -1

var has_resetted_during_board_win: bool = false
#var game_has_ended: bool = false

var saver_loader: SaverLoader = SaverLoader.new()

const ON_NEWGROUNDS_MIRROR = true


func _ready() -> void:
	add_child(saver_loader)
	
	load_game_data() 
	
	if ON_NEWGROUNDS_MIRROR:
		NG.on_session_change.connect(session_change)
		
		load_game_medals_data()
	
	game_end.connect(func():
		if !has_resetted_during_board_win:
			stage_complete()
			
		has_resetted_during_board_win = false
		)
	
	menu_entered.connect(func(entered: Menus):
		menu_id = entered
		)
	
	game_reset.connect(func():
		GameLogic.self_destruct()
		get_tree().reload_current_scene()
		)
	
	game_just_ended.connect(func():
		await get_tree().create_timer(GameUtil.get_board_complete_anim_waittime()).timeout
		game_end.emit()
	)


func session_change(s: NewgroundsSession) -> void:
	if s.is_signed_in():
		print("Newgrounds.io - Signed in")
		
	else:
		print("Newgrounds.io - Not signed in")
		
	await MedalMgr.unlock_a_medal("bokoblock", NewgroundsIds.MedalId.WelcomeToBokoblock)


func stage_complete() -> void:
	@warning_ignore("integer_division")
	if board_id / checkerboard_id == 10:
		checkerboard_complete()
	else:
		goto_next_stage()


func checkerboard_complete() -> void:
	if current_ui_handler:
		current_ui_handler.the_checkerboard_has_been_checkered()


## Goes to next stage.
## [br][br]Enabling [param force_progression] bypasses [member Board.stage_progression] and forces progression.
func goto_next_stage(force_progression: bool = false) -> void:
	if current_board:
		if !current_board.stage_progression && !force_progression:
			print("current_board.stage_progression is false, progression stopped.")
			return
	
	GameLogic.self_destruct()
	
	var next_lvl_id := board_id + 1
	var next_lvl_path := GameUtil.STAGE_FILE_BEGIN + str(next_lvl_id) + GameUtil.STAGE_FILE_END
	
	if next_lvl_id <= GameUtil.NUMBER_OF_BOARDS: 
		Trans.slide_to_next_stage(next_lvl_path)
	else:
		Trans.slide_to_credits(0.4)
		#game_has_ended = true


func goto_next_checkerboard() -> void:
	goto_next_stage(true)
	
	if board_id + 1 <= GameUtil.NUMBER_OF_BOARDS:
		await get_tree().create_timer(1.5).timeout
		Audio.set_music()

#### Config

signal reduce_motion_setting_set(is_on: bool)
signal colorblind_mode_setting_set(is_on: bool)

@onready var SFX_BUS_ID: int = AudioServer.get_bus_index("SFX")
@onready var Music_BUS_ID: int = AudioServer.get_bus_index("Music")

var _reduce_motion_on: bool = false:
	get:
		return _reduce_motion_on
	set(value):
		reduce_motion_setting_set.emit(value)
		_reduce_motion_on = value
var _colorblind_mode_on: bool = false:
	get:
		return _colorblind_mode_on
	set(value):
		colorblind_mode_setting_set.emit(value)
		_colorblind_mode_on = value
var _game_sfx_muted: bool = false:
	get:
		return _game_sfx_muted
	set(value):
		AudioServer.set_bus_mute(SFX_BUS_ID, value)
		_game_sfx_muted = value
var _game_music_muted: bool = false:
	get:
		return _game_music_muted
	set(value):
		AudioServer.set_bus_mute(Music_BUS_ID, value)
		_game_music_muted = value

func set_game_sfx_muted(value: bool) -> void:
	_game_sfx_muted = value


func get_game_sfx_muted_setting() -> bool:
	return _game_sfx_muted


func set_game_music_muted(value: bool) -> void:
	_game_music_muted = value


func get_game_music_muted_setting() -> bool:
	return _game_music_muted


func set_reduce_motion_setting(value: bool) -> void:
	_reduce_motion_on = value


func get_reduce_motion_setting() -> bool:
	return _reduce_motion_on


func set_colorblind_mode_setting(value: bool) -> void:
	_colorblind_mode_on = value


func get_colorblind_mode_setting() -> bool:
	return _colorblind_mode_on
	
####

func reset_game() -> void:
	game_reset.emit()


func reset_game_data() -> void:
	saver_loader.new_game()
	saver_loader.new_game_medals()


func save_game_data() -> void:
	saver_loader.save_game()


func load_game_data() -> void:
	saver_loader.load_game()


func save_game_medals_data() -> void:
	saver_loader.save_medals()


func load_game_medals_data() -> void:
	saver_loader.load_medals()


func process_waittime(wait: float = 0.05) -> void:
	await get_tree().create_timer(wait).timeout


func self_destruct() -> void: ## @deprecated
	pass
	
