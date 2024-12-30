## Runtime actor model
extends Node

signal level_entered(is_lvl: int)
signal game_just_ended()
signal game_end()
signal game_reset()

var number_of_bodies: int
var current_level: Level
var current_level_id: int:
	get:
		return current_level_id
	set(value):
		level_entered.emit(value)
		current_level_id = value
var current_bodies: Array[Bokobody]:
	get:
		return current_bodies
	set(value):
		number_of_bodies = value.size() # doesn't work, bummer
		current_bodies = value
var current_endpoints: Array[Endpoint]

var _is_game_manager_resetting: bool = false


func _ready() -> void:
	game_end.connect(goto_next_level)
	
	game_reset.connect(func():
		_reset_game_manager()
		get_tree().reload_current_scene()
		)
		
	level_entered.connect(func(_is_lvl: int):
		pass
		)
	
	game_just_ended.connect(func():
		await get_tree().create_timer(GameUtil.level_complete_anim_waittime).timeout
		game_end.emit()
	)
	
	await get_tree().create_timer(0.1).timeout
	number_of_bodies = current_bodies.size()


func goto_next_level() -> void:
	_reset_game_manager()
	GameLogic.self_detruct()
	
	var next_lvl_id := current_level_id + 1
	var next_lvl_path := GameUtil.LEVEL_FILE_BEGIN + str(next_lvl_id) + GameUtil.LEVEL_FILE_END

	if next_lvl_id <= GameUtil.NUMBER_OF_LEVELS:
		get_tree().change_scene_to_file(next_lvl_path)
		

func reset_game() -> void:
	game_reset.emit()


func self_detruct() -> void:
	_reset_game_manager()
	

func _reset_game_manager() -> void:
	if !_is_game_manager_resetting:
		_is_game_manager_resetting = true
		current_bodies = []
		current_endpoints = []
		number_of_bodies = 0
		
		await get_tree().create_timer(0.1).timeout
		number_of_bodies = current_bodies.size()
		_is_game_manager_resetting = false
