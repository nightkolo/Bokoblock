extends CanvasLayer
class_name GameplayUI

signal game_pause_toggled(is_paused: bool)

@onready var pause_menu: PauseMenu = $PauseMenu

var is_game_paused: bool = false:
	get:
		return is_game_paused
	set(value):
		get_tree().paused = value
		is_game_paused = value


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		pause_or_unpause()
		
	if event.is_action_pressed("game_reset"):
		if is_game_paused == false:
			reset_stage()
	
	if event.is_action_pressed("skip_level"):
		GameMgr.goto_next_stage(true)
		
	if event.is_action_pressed("prev_level"):
		GameMgr.goto_prev_stage()
	
	
func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	GameMgr.current_ui_handler = self
	
	
func pause_or_unpause() -> void:
	is_game_paused = !is_game_paused
	
	game_pause_toggled.emit(is_game_paused)
	
	pause_menu.visible = is_game_paused
	
	
func reset_stage() -> void:
	return_to_run()
	GameMgr.reset_game()


func return_to_run() -> void:
	is_game_paused = false
