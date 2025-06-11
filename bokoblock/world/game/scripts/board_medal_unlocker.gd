extends Node
class_name BoardMedalUnlockerComponent

enum BoardsWithMedals {
	M_1_4 = 0,
	M_1_5 = 1,
	M_1_6 = 2,
	M_2_14 = 3,
	M_2_15 = 4,
	M_2_20 = 5
}

@export var current_board: BoardsWithMedals

@export var body_of_interest_1: Bokobody
@export var body_of_interest_2: Bokobody


var has_hit_blackpoint: bool = false
var has_hit_sleepy_block: bool = false


func _ready() -> void:
	match current_board:
		BoardsWithMedals.M_1_4:
			GameMgr.game_data_saved.connect(func():
				if GameData.runtime_data["4"]["move_count"] <= 8:
					MedalMgr.unlocked("Your Moves are Precious")
					#MedalMgr.unlock_a_medal()
				else:
					print("couldn't unlock")
				)
		
		BoardsWithMedals.M_1_5:
			for block: Bokoblock in body_of_interest_1.child_blocks:
			
				block.body_entered.connect(func(body: Node2D):
					if body is SleepingBlock && !has_hit_sleepy_block:
						has_hit_sleepy_block = true
					)
					
			GameMgr.game_just_ended.connect(func():
				if !has_hit_sleepy_block:
					MedalMgr.unlocked("A Block for a Block")
					#MedalMgr.unlock_a_medal()
				else:
					print("couldn't unlock")
				)
		
		BoardsWithMedals.M_1_6:
			GameMgr.game_data_saved.connect(func():
				if GameData.runtime_data["6"]["move_count"] <= 14:
					MedalMgr.unlocked("Count your Steps")
					#MedalMgr.unlock_a_medal()
				else:
					print("couldn't unlock")
				)
		
		BoardsWithMedals.M_2_15:
			GameMgr.game_data_saved.connect(func():
				if GameData.runtime_data["15"]["move_count"] <= 22:
					MedalMgr.unlocked("Pharaoh's Tomb")
					#MedalMgr.unlock_a_medal()
				else:
					print("couldn't unlock")
				)
				
		BoardsWithMedals.M_2_14:
			body_of_interest_1.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
				
			body_of_interest_2.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
			
			GameMgr.game_just_ended.connect(func():
				print_debug(has_hit_blackpoint)
				
				if !has_hit_blackpoint:
					MedalMgr.unlocked("Watch your Step")
					#MedalMgr.unlock_a_medal()
				else:
					print("couldn't unlock")
			)
		
		BoardsWithMedals.M_2_20:
			body_of_interest_1.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
				
			body_of_interest_2.somebody_entered_blackpoint.connect(func():
				has_hit_blackpoint = true
				)
			
			GameMgr.game_just_ended.connect(func():
				print_debug(has_hit_blackpoint)
				
				if !has_hit_blackpoint:
					MedalMgr.unlocked("Blocks in Black")
					#MedalMgr.unlock_a_medal()
				else:
					print("couldn't unlock")
			)
			
