extends CanvasLayer
class_name GameplayUI

signal game_pause_toggled(is_paused: bool)
signal stage_complete_entered() ## @deprecated

@onready var pause_screen: PauseScreen = $PauseMenu
@onready var checkerboard_complete_screen: CBCompleteScreen = $StageCompleteScreen

var is_game_paused: bool = false:
	get:
		return is_game_paused
	set(value):
		get_tree().paused = value
		is_game_paused = value

const BBCODE_TXT = "
[outline_size=8][outline_color=#3f3f3f][color=#ffffff][center][font_size=37][wave amp=20.0 freq=2.0][tornado radius=2.5 freq=4.0]"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause") && !Trans.is_transitioning:
		match GameMgr.current_menu:
			GameMgr.Menus.RUNTIME, GameMgr.Menus.PAUSE:
				pause_or_unpause()
		
	if event.is_action_pressed("game_reset"):
		match GameMgr.current_menu:
			GameMgr.Menus.RUNTIME:
				reset_stage()
	
	#if event.is_action_pressed("skip_level"):
		#GameMgr.goto_next_stage(true)
		#
	#if event.is_action_pressed("prev_level"):
		#GameMgr.goto_prev_stage()
	
	
func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	GameMgr.current_ui_handler = self
	

func the_checkerboard_has_been_checkered():
	checkerboard_complete_screen.open()

	
func pause_or_unpause() -> void:
	if GameLogic.has_won:
		return
		
	if is_game_paused:
		GameMgr.menu_entered.emit(GameMgr.Menus.PAUSE)
		Audio.set_music(Audio.original_music_db - 15.0)
	else:
		GameMgr.menu_entered.emit(GameMgr.Menus.RUNTIME)
		Audio.set_music()
		
	is_game_paused = !is_game_paused
	
	game_pause_toggled.emit(is_game_paused)
	
	pause_screen.visible = is_game_paused
	
	
func reset_stage() -> void:
	Audio.play_reset_sound()
	return_to_run()
	GameMgr.reset_game()


func return_to_run() -> void:
	is_game_paused = false
