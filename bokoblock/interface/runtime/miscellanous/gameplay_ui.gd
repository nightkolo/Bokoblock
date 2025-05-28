extends CanvasLayer
class_name GameplayUI

signal game_pause_toggled(is_paused: bool)

@onready var pause_screen: PauseScreen = $PauseMenu
@onready var checkerboard_complete_screen: CBCompleteScreen = $StageCompleteScreen

var allow_input: bool = true
var is_game_paused: bool = false:
	get:
		return is_game_paused
	set(value):
		get_tree().paused = value
		is_game_paused = value

const BBCODE_TXT = "
[outline_size=8][outline_color=#3f3f3f][color=#ffffff][center][font_size=37][wave amp=20.0 freq=2.0][tornado radius=2.5 freq=4.0]"


func _unhandled_input(event: InputEvent) -> void:
	if allow_input:
		
		if event.is_action_pressed("game_pause") && !Trans.is_transitioning:
			match GameMgr.current_menu:
				
				GameMgr.Menus.RUNTIME, GameMgr.Menus.PAUSE:
					pause_or_unpause()
			
		if event.is_action_pressed("game_reset"):
			match GameMgr.current_menu:
				
				GameMgr.Menus.RUNTIME:
					reset_stage()
	
	
func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	allow_input = true
	
	GameMgr.current_ui_handler = self
	

func the_checkerboard_has_been_checkered():
	checkerboard_complete_screen.open()

	
func pause_or_unpause() -> void:
	if GameLogic.has_won:
		return
	
	is_game_paused = !is_game_paused
	
	if is_game_paused:
		GameMgr.menu_entered.emit(GameMgr.Menus.PAUSE)
		Audio.set_music(Audio.original_music_db - 15.0)
	else:
		GameMgr.menu_entered.emit(GameMgr.Menus.RUNTIME)
		Audio.set_music()
	
	game_pause_toggled.emit(is_game_paused)
	
	pause_screen.visible = is_game_paused


func quit() -> void:
	GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
	
	return_to_run()
	get_tree().change_scene_to_file("res://interface/menus/menu_board_select.tscn")

	
func reset_stage() -> void:
	Audio.play_reset_sound()
	return_to_run()
	GameMgr.reset_game()


func return_to_run() -> void:
	#Audio.set_music()
	is_game_paused = false
