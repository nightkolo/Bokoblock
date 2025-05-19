## Runtime actor model
extends Node

signal stage_entered(is_lvl: int)
signal menu_entered(entered: GameMenus)
signal game_just_ended()
signal game_end()
signal game_reset()
signal game_data_saved()
signal game_data_loaded()

enum GameMenus {
	MENUS = 0,
	PAUSE = 1,
	CHECKERBOARD_COMPLETE = 2,
	START = 3,
	RUNTIME = 99
}

var current_menu: GameMenus = GameMenus.START

var current_ui_handler: GameplayUI
var current_stage: Stage
var current_stage_id: int = -1:
	get:
		return current_stage_id
	set(value):
		stage_entered.emit(value)
		current_stage_id = value
var current_checkerboard_id: int = -1
var current_bodies: Array[Bokobody]
var current_blocks: Array[Bokoblock]
var current_starpoints: Array[Starpoint]

var saver_loader: SaverLoader = SaverLoader.new()

const ON_NEWGROUNDS_MIRROR = true

var _is_game_manager_resetting: bool = false
var sfx_muted: bool = false
var music_muted: bool = false


func _ready() -> void:
	add_child(saver_loader)
	
	#load_game_data()
	
	game_end.connect(stage_completed)
	
	menu_entered.connect(func(entered: GameMenus):
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


func stage_completed() -> void:
	if current_stage_id == 10:
		open_checkerboard_complete_screen()
	else:
		goto_next_stage()


func open_checkerboard_complete_screen() -> void:
	if current_ui_handler:
		current_ui_handler.the_checkboard_is_done()


## Goes to next stage.
## [br][br]Enabling [param force_progression] bypasses [member Stage.stage_progression] and forces progression.
func goto_next_stage(force_progression: bool = false) -> void:
	if current_stage:
		if !current_stage.stage_progression && !force_progression:
			print("current_stage.stage_progression is false, progression stopped.")
			return
	
	_reset_game_manager()
	GameLogic.self_destruct()
	
	var next_lvl_id := current_stage_id + 1
	var next_lvl_path := GameUtil.STAGE_FILE_BEGIN + str(next_lvl_id) + GameUtil.STAGE_FILE_END
	
	if next_lvl_id <= GameUtil.NUMBER_OF_STAGES: 
		Trans.slide_to_next_stage(next_lvl_path)


func goto_next_checkerboard() -> void:
	print("Beta finished.")
	
	Trans.slide_to_next_stage("res://interface/menus/thank_you_screen.tscn")


func goto_prev_stage() -> void:
	if current_stage:
		return
	
	_reset_game_manager()
	GameLogic.self_destruct()
	
	var next_lvl_id := current_stage_id - 1
	var next_lvl_path := GameUtil.STAGE_FILE_BEGIN + str(next_lvl_id) + GameUtil.STAGE_FILE_END
	
	if next_lvl_id <= GameUtil.NUMBER_OF_STAGES: 
		get_tree().change_scene_to_file(next_lvl_path)


func reset_progress() -> void:
	saver_loader.new_game()


func save_game_data() -> void:
	saver_loader.save_game()


func load_game_data() -> void:
	saver_loader.load_game()
	

#var current_card_ui: TestCardUI ## @experimental
#
#
#func get_card_type() -> TestCardUI.CardType: ## @experimental
	#return current_card_ui.current_card_type


func reset_game() -> void:
	game_reset.emit()


func process_waittime(wait: float = 0.05) -> void: ## @deprecated
	await get_tree().create_timer(wait).timeout


func self_destruct() -> void:
	_reset_game_manager()
	

func _reset_game_manager() -> void:
	if !_is_game_manager_resetting:
		_is_game_manager_resetting = true
		current_bodies = []
		current_blocks = []
		current_starpoints = []
		
		await get_tree().create_timer(0.1).timeout
		_is_game_manager_resetting = false
