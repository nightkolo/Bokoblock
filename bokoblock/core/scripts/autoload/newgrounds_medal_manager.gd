## @experimental
## Newgrounds Medal and Stat Manager (autoload)
## MedalMgr
extends Node

var _save_cool_down: Timer = Timer.new()


func _ready() -> void:
	if not GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	GameMgr.game_data_saved.connect(func():
		#if GameMgr.current_board.improved_stats:
		check_stage_progression_medals(GameMgr.current_checkboard_id)
	)

	GameLogic.state_checked.connect(func(have_moved: bool):
		# Move, Turn
		if !have_moved:
			update_player_stats(true)

		#update_player_stats(true, true)
		)
	#GameLogic.bodies_undoed.connect(func():
		## Undo
		#update_player_stats(false, true)
		#)

# moves_made = true, move, turn //// moves_made = false, undo
#func update_player_stats(move_made: bool, check_medals: bool = true):
func update_player_stats(check_medals: bool = true):
	# var tranformed_to: GameLogic.TransformationType = PlayerInput.last_input

	# match typeof(tranformed_to):

	#	 GameLogic.TransformationType.TURN, GameLogic.TransformationType.MOVE:
	#	 if !GameLogic.we_have_made_a_move:
	#	 return

	#	 GameData.runtime_data["moves_mades"] += 1

	#	 GameLogic.TransformationType.UNDO:
	#	 GameData.runtime_data["undos_mades"] += 1
	
	#if move_made:
	GameData.runtime_data["moves_mades"] += 1
	#else:
		#GameData.runtime_data["undos_mades"] += 1

	# TODO: Add cool down
	# GameMgr.save_game_data()

	if check_medals:
		check_player_stat_medals()
	

func check_player_stat_medals():
	if GameData.runtime_data["move_mades"] > 200:
		# await _unlock_a_medal()
		pass
	elif GameData.runtime_data["move_mades"] > 500:
		# await _unlock_a_medal()
		pass

	#if GameData.runtime_data["undos_mades"] > 75:
		## await _unlock_a_medal()
		#pass
	#elif GameData.runtime_data["undos_mades"] > 200:
		## await _unlock_a_medal()
		#pass
	

func check_stage_progression_medals(checkerboard: int = 1) -> void:
	#var all_completed: bool = _check_cb_progression(checkerboard, "completed")
	var all_completed: bool = _check_cb_progression(checkerboard)
	
	#var all_starred: bool = _check_cb_progression(checkerboard, "starred")
	var entry: String = "10" + str(checkerboard)

	if GameData.runtime_data[entry]["completed"] == false:
		GameData.runtime_data[entry]["completed"] = all_completed

		if all_completed:
			# await _unlock_a_medal()
			pass

	#if GameData.runtime_data[entry]["starred"] == false:
		#GameData.runtime_data[entry]["starred"] = all_starred
#
		#if all_starred:
			## await _unlock_a_medal()
			#pass
	

func _unlock_a_medal(_medal_id: int):
	#await NG.medal_unlock(medal_id)
	pass
		

#func _check_cb_progression(cb: int, look_for: String) -> bool:
func _check_cb_progression(cb: int) -> bool:
	# if !(look_for == "completed" || look_for == "starred"):
	#	 return

	if (cb < 0 || cb > GameUtil.NUMBER_OF_CHECKERBOARDS):
		return 0

	var begin: int = 1 * ((	cb - 1) + 10)
	var end: int = 11 * ((cb - 1) + 10)

	for i: int in range(begin, end):
		#if GameData.runtime_data[str(i)][look_for] == true:
		if GameData.runtime_data[str(i)]["completed"] == true:
			return true

	return 0
