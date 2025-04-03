extends Node

signal bokobodies_moved(transformed_to)
signal bokobody_stopped()
signal bokobodies_stopped()
signal bokobody_entered_starpoint()
signal bokobody_exited_starpoint()
signal stage_won()

enum WinCondition {
	MATCH_ALL_STARPOINTS = 0,
	MATCH_ALL_BLOCKS = 1
}
enum TranformationType { ## @experimental
	MOVE = 0,
	TURN = 1,
	UNDO = 99
}

static var win_condition: WinCondition

var has_won: bool = false
var win_checked: bool = true
var are_bodies_moving: bool = false
var is_block_on_starpoint: bool = false

var _bodies_stopped: int = 0


func _ready() -> void:
	bokobody_stopped.connect(check_if_bodies_stopped)
	bokobodies_stopped.connect(check_win)
	bokobodies_stopped.connect(check_bodies)
	
	GameMgr.game_reset.connect(_reset_game_logic)
	
	stage_won.connect(func():
		GameMgr.game_just_ended.emit()
		)


static func set_win_condition(win_cond: WinCondition) -> void:
	win_condition = win_cond


func check_bodies() -> void:
	await GameMgr.process_waittime()
	
	var block_has_stood_on_starpoint: bool = check_if_block_on_starpoint(GameMgr.current_blocks)
	
	if block_has_stood_on_starpoint && !is_block_on_starpoint:
		bokobody_entered_starpoint.emit()
		is_block_on_starpoint = true
	elif !block_has_stood_on_starpoint && is_block_on_starpoint:
		bokobody_exited_starpoint.emit()
		is_block_on_starpoint = false


func check_if_bodies_stopped() -> void:
	var num_of_bodies: int = GameMgr.current_bodies.size()
	
	if num_of_bodies == 0:
		return
	
	_bodies_stopped += 1
	
	are_bodies_moving = _bodies_stopped != num_of_bodies
	
	if !are_bodies_moving:
		bokobodies_stopped.emit()
		_bodies_stopped = 0


func check_win() -> void:
	var match_amount: int = 0
	var objects_happy: int = 0
	
	match win_condition:
		
		WinCondition.MATCH_ALL_STARPOINTS:
			match_amount = GameMgr.current_starpoints.size()
			
		WinCondition.MATCH_ALL_BLOCKS:
			if GameMgr.current_stage.custom_block_match < 0:
				match_amount = GameMgr.current_blocks.size()
			else:
				match_amount = GameMgr.current_stage.custom_block_match
	
	if match_amount == 0:
		win_checked = true
		return
	
	for starpoint: Starpoint in GameMgr.current_starpoints:
		if starpoint.check_satisfaction():
			objects_happy += 1
	
	has_won = objects_happy == match_amount
	
	if has_won:
		win_stage()
		
	win_checked = true


func win_stage() -> void:
	stage_won.emit()
	print("Game over.")


func can_move() -> bool:
	return !are_bodies_moving && win_checked && !has_won


func has_moved() -> void:
	are_bodies_moving = true
	win_checked = false


func get_current_win_condition() -> WinCondition:
	if GameMgr.current_stage:
		return GameMgr.current_stage.win_condition
	
	return 0


func check_if_block_on_starpoint(blocks: Array[Bokoblock]) -> bool:
	if blocks.is_empty():
		return false
		
	for block: Bokoblock in blocks:
		return block.is_on_starpoint
		#if block.is_on_starpoint:
			#return true
	
	return false


func self_destruct() -> void:
	_reset_game_logic()


func _reset_game_logic() -> void:
	has_won = false
	win_checked = true
	are_bodies_moving = false
