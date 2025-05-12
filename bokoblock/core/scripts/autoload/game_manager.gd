## Runtime actor model
extends Node

signal stage_entered(is_lvl: int)
signal world_entered(is_wrld: int)
signal game_entered(entered: bool)
#signal stage_completed_screen_entered(entered: bool)
#signal game_exited()
signal game_just_ended()
signal game_end()
signal game_reset()

var in_game: bool = false
var in_stage_complete = false ## @experimental

var number_of_bodies: int ## @deprecated
var current_ui_handler: GameplayUI
var current_stage: Stage
var current_stage_id: int = -1:
	get:
		return current_stage_id
	set(value):
		stage_entered.emit(value)
		current_stage_id = value
var current_world_id: int = -1:
	get:
		return current_world_id
	set(value):
		world_entered.emit(value)
		current_world_id = value
var current_bodies: Array[Bokobody]
var current_blocks: Array[Bokoblock]
var current_starpoints: Array[Starpoint]

var _is_game_manager_resetting: bool = false


func _ready() -> void:
	Engine.time_scale = 1.0/1.0
	
	game_end.connect(goto_next_stage)
	
	game_entered.connect(func(entered: bool):
		in_game = entered
		)
		
	#stage_completed_screen_entered.connect(func(entered: bool):
		#in_stage_complete = entered
		#)
	
	game_reset.connect(func():
		_reset_game_manager()
		get_tree().reload_current_scene()
		)
		
	stage_entered.connect(func(_is_lvl: int):
		pass
		)
	
	game_just_ended.connect(func():
		# Awaits  complete animation
		await get_tree().create_timer(GameUtil.stage_complete_anim_waittime).timeout
		game_end.emit()
	)
	
	await get_tree().create_timer(0.1).timeout
	number_of_bodies = current_bodies.size()


func open_stage_complete() -> void: ## @experimental
	if !in_game:
		return
	
	print("Stage complete")
	
	
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
		get_tree().change_scene_to_file(next_lvl_path)


func goto_prev_stage() -> void:
	if current_stage:
		return
	
	_reset_game_manager()
	GameLogic.self_destruct()
	
	var next_lvl_id := current_stage_id - 1
	var next_lvl_path := GameUtil.STAGE_FILE_BEGIN + str(next_lvl_id) + GameUtil.STAGE_FILE_END
	
	if next_lvl_id <= GameUtil.NUMBER_OF_STAGES: 
		get_tree().change_scene_to_file(next_lvl_path)


var current_card_ui: TestCardUI ## @experimental


func get_card_type() -> TestCardUI.CardType: ## @experimental
	return current_card_ui.current_card_type


func reset_game() -> void:
	game_reset.emit()


func process_waittime(wait: float = 0.05) -> void:
	await get_tree().create_timer(wait).timeout


func self_destruct() -> void:
	_reset_game_manager()
	

func _reset_game_manager() -> void:
	if !_is_game_manager_resetting:
		_is_game_manager_resetting = true
		current_bodies = []
		current_blocks = []
		current_starpoints = []
		number_of_bodies = 0
		
		await get_tree().create_timer(0.1).timeout
		number_of_bodies = current_bodies.size()
		_is_game_manager_resetting = false
