## @experimental
## Newgrounds Medal and Stat Manager (autoload)
## MedalMgr
extends Node


func _ready() -> void:
	if not GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	GameMgr.game_data_saved.connect(func():
		check_stage_progression_medals()
		check_player_stat_medals()
	)

	GameLogic.state_checked.connect(func(have_moved: bool):
		# Move, Turn
		if have_moved:
			update_player_moves_stat()
		)


func update_player_moves_stat():
	GameData.runtime_data["moves_made"] += 1

func check_player_stat_medals() -> void:
	if GameData.runtime_data["moves_made"] > 200:
		# await unlock_a_medal()
		unlocked("Move King")
	elif GameData.runtime_data["moves_made"] > 600:
		# await unlock_a_medal()
		unlocked("Move Maestro")
		
	#checked("Move medals", GameData.runtime_data["moves_made"])


func check_stage_progression_medals() -> void:
	checked("Checkerboard 1 Complete", GameData.runtime_data["101"]["completed"])
	checked("Checkerboard 2 Complete", GameData.runtime_data["102"]["completed"])
	checked("Poko Approves", GameData.runtime_data["101"]["completed"] == true && GameData.runtime_data["102"]["completed"] == true)
	
	if GameData.runtime_data["101"]["completed"] == true:
		unlocked("Checkerboard 1 Complete")
		# await unlock_a_medal()
	
			
	if GameData.runtime_data["102"]["completed"] == true:
		unlocked("Checkerboard 2 Complete")
		# await unlock_a_medal()
			
	
	if GameData.runtime_data["101"]["completed"] == true && GameData.runtime_data["102"]["completed"] == true:
		unlocked("Poko Approves")
		# await unlock_a_medal()
	

func unlock_a_medal(medal_entry: bool, _medal_id: int):
	if !medal_entry:
		pass
	
		#await NG.medal_unlock(medal_id)
		
		GameMgr.save_game_medals_data()



func checked(medal_example: String, res):
	print("Checked: ", medal_example, ". Result: ", str(res))


func unlocked(medal_example: String):
	print("Unlocked: ", medal_example)
