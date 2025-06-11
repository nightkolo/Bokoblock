## @experimental
## Newgrounds Medal and Stat Manager (autoload)
## MedalMgr
extends Node


func _ready() -> void:
	if not GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	# Medals are checkered when GameMgr.game_data_saved is emitted
	# GameMgr.game_data_saved is emitted by Stage (Level code) on GameMgr.game_just_ended.
	# Stage sets the runtime_data,
	# then this autoload checks for progression medals.
	GameMgr.game_data_saved.connect(func():
		check_board_progression_medals()
		check_player_stat_medals()
	)

	GameLogic.state_checked.connect(func(have_moved: bool):
		if have_moved:
			update_player_moves_stats()
		)
	
	
#func unlock_a_medal(medal_code: String, _medal_id: int) -> void:
## @experimental
## Unlocks the Newgrounds medals by their[br]
## [param medal_code]: The medal code (the game uses to store data) for the medal.[br]
## [param medal_id]: The medal ID (Newgrounds.io uses to unlock on newgrounds.com) for the medal.
func unlock_a_medal(medal_code: String) -> void:
	
	if not GameData.medal_data.has(medal_code):
		print("Could not find " + str(medal_code) + " in GameData.medal_data.")
		return
	
	if GameData.medal_data[medal_code] == false:
		GameData.medal_data[medal_code] = true
	
		#await NG.medal_unlock(medal_id)
		
		print("Medal unlocked: ", medal_code)
		
		GameMgr.save_game_medals_data()


func update_player_moves_stats():
	GameData.runtime_data["moves_made"] += 1


func check_player_stat_medals() -> void:
	if GameData.runtime_data["moves_made"] > 200:
		unlock_a_medal("200moves")
		
	elif GameData.runtime_data["moves_made"] > 600:
		unlock_a_medal("600moves")


func check_board_progression_medals() -> void:
	#checked("Checkerboard 1 Complete", GameData.runtime_data["101"]["completed"])
	#checked("Checkerboard 2 Complete", GameData.runtime_data["102"]["completed"])
	#checked("Poko Approves", GameData.runtime_data["101"]["completed"] == true && GameData.runtime_data["102"]["completed"] == true)
	#
	if GameData.runtime_data["101"]["completed"] == true:
		unlocked("Checkerboard 1 Complete")
		unlock_a_medal("cb1_comp")
			
	if GameData.runtime_data["102"]["completed"] == true:
		unlocked("Checkerboard 2 Complete")
		unlock_a_medal("cb2_comp")
	
	if GameData.runtime_data["101"]["completed"] == true && GameData.runtime_data["102"]["completed"] == true:
		unlocked("Poko Approves")
		unlock_a_medal("game_comp")


func checked(medal_example: String, res): ## @deprecated
	print("Checked: ", medal_example, ". Result: ", str(res))


func unlocked(_medal_example: String): ## @deprecated
	#print("Unlocked: ", medal_example)
	pass
