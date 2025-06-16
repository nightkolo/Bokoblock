## @experimental
## [Board] Component for unlocking Board-specific medals.
extends Node
class_name BoardMedalUnlockerComponent

@export var body_of_interest_1: Bokobody
@export var body_of_interest_2: Bokobody

var has_hit_blackpoint: bool = false
var has_hit_sleepy_block: bool = false

# Unlock checks can cause a complicated issue:
# GameData.medal_data only checks for browser sessions, and not the Newgrounds Account specifically.
# Why is this a problem? well, if a user unlocks some medals on a Newgrounds account,
# Then switch to another Newgrounds account (staying on the same browser),  
# The user wouldn't be able to unlock those medals on that account, as again...
# GameData.medal_data only checks for BROWSER SESSIONS, and NOT the Newgrounds Account.
# Thus, I can't do an unlock check, and instead unlock a medal at all costs. 
# I'm also honestly not skilled enough to troubleshoot this :(


func _ready() -> void:
	GameMgr.game_data_saved.connect(func():
		# Checks for move count medals
		# It is made awkwardly this way
		
		match GameMgr.board_id:
			
			4:
				if !GameData.runtime_data.has("4"):
					print("Cannot check move count medals. Key %s not found in GameData.runtime_data." % str(GameMgr.board_id))
					return
					
				if GameData.runtime_data["4"]["move_count"] <= 5:
					
					if GameData.medal_data.has("4_1") && GameMgr.current_ui_handler:
						if GameData.medal_data["4_1"] == false:
							GameMgr.current_ui_handler.a_medal_has_been_unlocked()
					
					# Turns medal_data["4_1"] to true and unlocks medal.
					await MedalMgr.unlock_a_medal("4_1", NewgroundsIds.MedalId.YourMovesArePrecious)
			
			6:
				if !GameData.runtime_data.has("6"):
					print("Cannot check move count medals. Key %s not found in GameData.runtime_data." % str(GameMgr.board_id))
					return
				
				if GameData.runtime_data["6"]["move_count"] <= 14:
					
					if GameData.medal_data.has("6_1") && GameMgr.current_ui_handler:
						if GameData.medal_data["6_1"] == false:
							GameMgr.current_ui_handler.a_medal_has_been_unlocked()
					
					await MedalMgr.unlock_a_medal("6_1", NewgroundsIds.MedalId.CountYourSteps)
			
			15:
				if !GameData.runtime_data.has("15"):
					print("Cannot check move count medals. Key %s not found in GameData.runtime_data." % str(GameMgr.board_id))
					return
				
				if GameData.runtime_data["15"]["move_count"] <= 22:
					
					if GameData.medal_data.has("15_1") && GameMgr.current_ui_handler:
						if GameData.medal_data["15_1"] == false:
							GameMgr.current_ui_handler.a_medal_has_been_unlocked()
						
					await MedalMgr.unlock_a_medal("15_1", NewgroundsIds.MedalId.LocomoteReaper)
		)
	
	GameMgr.game_just_ended.connect(func():
		# Checks for condition medals
		
		match GameMgr.board_id:
			
			5:
				#if not GameData.medal_data.has("5_1"):
					#return
				
				if !has_hit_sleepy_block:
					if GameMgr.current_ui_handler:
						GameMgr.current_ui_handler.a_medal_has_been_unlocked()
					
					# Unlock checks can cause a complicated issue
					# GameData.medal_data only checks for browser sessions, and not the Newgrounds Account specifically
					# Thus, I can't do an unlock check, and instead unlock a medal at all costs. 
					# I'm also hoesntly not skilled enough to troubleshooting this.
					
					#if GameData.medal_data["5_1"] == false:
					await MedalMgr.unlock_a_medal("5_1", NewgroundsIds.MedalId.ABlockForABlock)
			
			14:
				if !has_hit_blackpoint:
					if GameMgr.current_ui_handler:
						GameMgr.current_ui_handler.a_medal_has_been_unlocked()

					await MedalMgr.unlock_a_medal("14_1", NewgroundsIds.MedalId.WatchYourStep)
			
			20:
				if !has_hit_blackpoint:
					if GameMgr.current_ui_handler:
						GameMgr.current_ui_handler.a_medal_has_been_unlocked()
					
					await MedalMgr.unlock_a_medal("20_1", NewgroundsIds.MedalId.BlackIsYourEnemy)
		)
	
	await get_tree().create_timer(0.1).timeout
	
	has_hit_blackpoint = false
	has_hit_sleepy_block = false
	
	match GameMgr.board_id:
		# Processes condition medals
		
		5:
			has_hit_sleepy_block = false
			
			if !(body_of_interest_1):
				return
			
			for block: Bokoblock in body_of_interest_1.child_blocks:
			
				block.body_entered.connect(func(body: Node2D):
					if body is SleepingBlock && !has_hit_sleepy_block:
						has_hit_sleepy_block = true
					)
					
			for block: Bokoblock in body_of_interest_1.child_blocks:
				block.body_detected.connect(func(body: Node2D):
					if body is SleepingBlock && !has_hit_sleepy_block:
						has_hit_sleepy_block = true
					)
		
		14:
			has_hit_blackpoint = false
			
			if !(body_of_interest_1 && body_of_interest_2):
				return
			
			body_of_interest_1.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
				
			body_of_interest_2.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
		
		20:
			has_hit_blackpoint = false
			
			if !(body_of_interest_1 && body_of_interest_2):
				return
			
			body_of_interest_1.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
				
			body_of_interest_2.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
