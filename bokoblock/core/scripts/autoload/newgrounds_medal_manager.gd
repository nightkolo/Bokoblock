## Newgrounds Medal and Stat Manager
extends Node


func _ready() -> void:
	if not GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	# Medals are checkered when GameMgr.game_data_saved is emitted
	# GameMgr.game_data_saved is emitted by Stage (Level code) on GameMgr.game_just_ended.
	# Stage sets the runtime_data,
	# then this autoload checks for progression medals from runtime_data.
	GameMgr.game_data_saved.connect(func():
		check_board_progression_medals()
		check_player_stat_medals()
	)

	GameLogic.state_checked.connect(func(have_moved: bool):
		if have_moved:
			update_player_moves_stats()
		)
	
	
## Unlocks the Newgrounds medals by their[br]
## [param medal_code]: The medal code (the game uses to store data) for the medal.[br]
## [param medal_id]: The medal ID (Newgrounds.io uses to unlock medals on newgrounds.com) for the medal.[br][br]
## Must be called with [code]await[/code]
func unlock_a_medal(medal_code: String, medal_id: int) -> void:
	if !GameData.medal_data.has(medal_code):
		print("Could not find " + str(medal_code) + " in GameData.medal_data.")
	
	# Unlock checks can cause a complicated issue:
	# GameData.medal_data only checks for browser sessions, and not the Newgrounds Account specifically.
	# Why is this a problem? well, if a user unlocks some medals on a Newgrounds account,
	# Then switches to another Newgrounds account (staying on the same browser),  
	# The user wouldn't be able to unlock those medals on that account, as again...
	# GameData.medal_data only checks for BROWSER SESSIONS, and NOT the Newgrounds Account.
	# Thus, I can't do an unlock check, and instead unlock the medal at all costs. 
	# ....I'm also honestly not skilled enough to troubleshoot this :(
	
	await NG.medal_unlock(medal_id)
	
	## Debug
	#var medals: Array[MedalResource] = await NG.medal_get_list()
	#
	#for medal: MedalResource in medals:
		#if medal.id == medal_id:
			#print("Medal Name: " + str(medal.name) + ". ID: " + str(medal.id) + ". Unlocked: " + str(medal.unlocked))
			#break
	
	if !GameData.medal_data.has(medal_code):
		return
	
	if GameData.medal_data[medal_code] == false:
		GameData.medal_data[medal_code] = true
		
		print("Medal unlocked (code): ", medal_code)
		
		GameMgr.save_game_medals_data()
	

func update_player_moves_stats() -> void:
	if GameData.runtime_data.has("moves_made"):
		GameData.runtime_data["moves_made"] += 1


func check_player_stat_medals() -> void:
	if !GameData.runtime_data.has("moves_made"):
		return

	if GameData.runtime_data["moves_made"] > 200:
		await unlock_a_medal("200moves", NewgroundsIds.MedalId.MoveKing)
		
	elif GameData.runtime_data["moves_made"] > 600:
		await unlock_a_medal("600moves", NewgroundsIds.MedalId.MoveMaestro)


func check_board_progression_medals() -> void:
	if GameData.runtime_data.has("101") && GameData.runtime_data.has("102"):

		if GameData.runtime_data["101"]["completed"] == true:
			await unlock_a_medal("cb1_comp", NewgroundsIds.MedalId.Checkerboard1Complete)
				
		if GameData.runtime_data["102"]["completed"] == true:
			await unlock_a_medal("cb2_comp", NewgroundsIds.MedalId.Checkerboard2Complete)
		
		if GameData.runtime_data["101"]["completed"] == true && GameData.runtime_data["102"]["completed"] == true:
			await unlock_a_medal("game_comp", NewgroundsIds.MedalId.PokoApproves)
