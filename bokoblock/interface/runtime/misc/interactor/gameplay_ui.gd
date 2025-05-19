extends CanvasLayer
class_name GameplayUI

signal game_pause_toggled(is_paused: bool)
signal stage_complete_entered() ## @deprecated

@onready var pause_screen: PauseScreen = $PauseMenu
@onready var stage_complete_screen: StageCompleteScreen = $StageCompleteScreen


var is_game_paused: bool = false:
	get:
		return is_game_paused
	set(value):
		get_tree().paused = value
		is_game_paused = value


## @experimental
func update_text(bbcode: String, begin: String, end: String) -> String:
	return bbcode + begin + str(GameMgr.current_checkboard_id) + "-" + str(GameMgr.current_stage_id) + end


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		pause_or_unpause()
		
	if event.is_action_pressed("game_reset"):
		if is_game_paused == false:
			reset_stage()
	
	#if event.is_action_pressed("skip_level"):
		#GameMgr.goto_next_stage(true)
		#
	#if event.is_action_pressed("prev_level"):
		#GameMgr.goto_prev_stage()
	
	
func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	GameMgr.game_end.connect(the_blocks_have_been_happy)
	
	GameMgr.current_ui_handler = self
	
	
func the_blocks_have_been_happy():
	pass
	#stage_complete_entered.emit()
	
	#stage_complete_screen.anim_open()


func the_checkboard_is_done():
	stage_complete_screen.open()

	
func pause_or_unpause() -> void:
	if GameLogic.has_won:
		return
		
	is_game_paused = !is_game_paused
	
	game_pause_toggled.emit(is_game_paused)
	
	pause_screen.visible = is_game_paused
	
	if is_game_paused:
		GameMgr.menu_entered.emit(GameMgr.GameMenus.PAUSE)
	else:
		GameMgr.menu_entered.emit(GameMgr.GameMenus.RUNTIME)
	
	
func reset_stage() -> void:
	return_to_run()
	GameMgr.reset_game()


func return_to_run() -> void:
	is_game_paused = false
