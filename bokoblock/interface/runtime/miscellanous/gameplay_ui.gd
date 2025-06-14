extends CanvasLayer
class_name GameplayUI

signal game_pause_toggled(is_paused: bool)

@onready var pause_screen: PauseScreen = $PauseMenu
@onready var checkerboard_complete_screen: CBCompleteScreen = $StageCompleteScreen
@onready var medal_unlocked_popup: MedalUnlockedPopup = $MedalUnlockedPopup


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
	if allow_input && !Trans.is_transitioning: # Bruh.
		
		if event.is_action_pressed("game_pause"):
			match GameMgr.current_menu:
				
				GameMgr.Menus.RUNTIME, GameMgr.Menus.PAUSE:
					pause_or_unpause()
			
		if event.is_action_pressed("game_reset"):
			match GameMgr.current_menu:
				
				GameMgr.Menus.RUNTIME:
					reset_stage()
					
		if event.is_action_pressed("skip_level"):
			GameMgr.goto_next_stage()
		#
		#if event.is_action_pressed("prev_level"):
			#GameMgr.goto_prev_stage()
		
	
	
func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	allow_input = true
	
	GameMgr.current_ui_handler = self
	game_pause_toggled.connect(func(is_paused: bool):
		GameMgr.game_pause_toggled.emit(is_paused)
		)
	

func a_medal_has_been_unlocked() -> void:
	medal_unlocked_popup.anim_medal_unlocked()
	
	
func the_checkerboard_has_been_checkered() -> void: ## ???
	checkerboard_complete_screen.open()

	
func pause_or_unpause(pause: bool = !is_game_paused) -> void:
	if GameLogic.has_won:
		return
	
	is_game_paused = pause
	
	if is_game_paused:
		GameMgr.menu_entered.emit(GameMgr.Menus.PAUSE)
		
		Audio.game_paused.play()
		Audio.set_music(Audio.original_music_db - 15.0)
	else:
		GameMgr.menu_entered.emit(GameMgr.Menus.RUNTIME)
		
		Audio.game_start.play()
		Audio.set_music()
	
	game_pause_toggled.emit(is_game_paused)
	
	pause_screen.visible = is_game_paused


func quit() -> void:
	GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
	
	return_to_run()
	Trans.slide_to_scene("res://interface/menus/main_menus_scene.tscn")

	
func reset_stage() -> void:
	if Trans.is_transitioning:
		return
		
	#is_resetting = true
	
	Audio.play_reset_sound()
	return_to_run()
	#GameMgr.reset_game()
	Trans.reset_board()
	
	#is_resetting = false
	

func return_to_run() -> void:
	#Audio.set_music()
	is_game_paused = false
	
	pause_screen.visible = false
	
