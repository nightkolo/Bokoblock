extends Node

#signal button_held(is_bokocolor: GameUtil.BokoColor) ## @experimental
#signal button_released(is_bokocolor: GameUtil.BokoColor) ## @experimental

# i hate this

signal bokobody_move_hit()
signal bokobody_turn_hit()
signal bokobodies_moved(transformed_to)
signal bokobody_stopped(is_bokobody: Bokobody)
signal bokobodies_stopped()
signal bokobodies_stopped_making_move()
signal bokobody_entered_starpoint()
signal bokobody_exited_starpoint()
signal state_checked()
signal stage_won()

enum WinCondition {
	MATCH_ALL_STARPOINTS = 0,
	MATCH_ALL_BLOCKS = 1
}
enum TransformationType { ## uhh
	MOVE = 0,
	TURN = 1,
	UNDO = 99
}

static var win_condition: WinCondition

var has_won: bool = false
var win_checked: bool = true:
	set(value):
		#print_debug(value)
		win_checked = value
var are_bodies_moving: bool = false:
	set(value):
		#print_debug(value)
		are_bodies_moving = value
var is_block_on_starpoint: bool = false
var match_amount: int = 0

var _bodies_stopped: int = 0
var _prev_positions: Array[Transform2D]
var we_have_made_a_move: bool


func _bodies_have_moved() -> void:
	_prev_positions = []
		
	for body: Bokobody in GameMgr.current_bodies:
		_prev_positions.append(body.transform)


func _bodies_have_stopped() -> void:
	for i in range(GameMgr.current_bodies.size()):
		print(GameMgr.current_bodies[i].transform)
		print(_prev_positions[i])
	
	we_have_made_a_move = check_if_bodies_made_move()
	print(we_have_made_a_move)
	
	state_checked.emit()
	


func check_if_bodies_made_move() -> bool:
	if GameMgr.current_bodies.is_empty():
		return false
	
	for i: int in range(GameMgr.current_bodies.size()):
		if _prev_positions[i] != GameMgr.current_bodies[i].transform:
			return true
		
	return false


func _ready() -> void:
	bokobody_stopped.connect(check_if_bodies_stopped)
	bokobodies_stopped.connect(check_win)
	bokobodies_stopped.connect(check_bodies)
	
	PlayerInput.input_move.connect(func(_p):
		_bodies_have_moved()
		)
	PlayerInput.input_turn.connect(func(_p):
		_bodies_have_moved()
		)
		
	bokobodies_stopped_making_move.connect(_bodies_have_stopped)
	
	GameMgr.game_reset.connect(_reset_game_logic)
	
	check_bodies()
	
	stage_won.connect(func():
		GameMgr.game_just_ended.emit()
		)
		
	await get_tree().create_timer(0.1).timeout
	check_win()


static func set_win_condition(win_cond: WinCondition) -> void:
	win_condition = win_cond


func check_bodies() -> void:
	await GameMgr.process_waittime()
	
	var block_has_stood_on_starpoint: bool = check_if_block_on_starpoint(GameMgr.current_blocks)
	
	#print(block_has_stood_on_starpoint)
	#for block: Bokoblock in GameMgr.current_blocks:
		#print(block.is_on_starpoint)
	
	if block_has_stood_on_starpoint && !is_block_on_starpoint:
		bokobody_entered_starpoint.emit()
		is_block_on_starpoint = true
	elif !block_has_stood_on_starpoint && is_block_on_starpoint:
		bokobody_exited_starpoint.emit()
		is_block_on_starpoint = false


func check_if_bodies_stopped(_is_bokobody: Bokobody) -> void:
	var num_of_bodies: int = GameMgr.current_bodies.size()
	
	if num_of_bodies == 0:
		return
	
	_bodies_stopped += 1
	
	are_bodies_moving = _bodies_stopped != num_of_bodies
	
	if !are_bodies_moving:
		if PlayerInput.last_input != TransformationType.UNDO:
			bokobodies_stopped_making_move.emit()
		bokobodies_stopped.emit()
		_bodies_stopped = 0


func check_win() -> void:
	#var match_amount: int = 0
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
		if block.is_on_starpoint:
			return true
	
	return false


func self_destruct() -> void:
	_reset_game_logic()


func _reset_game_logic() -> void:
	has_won = false
	win_checked = true
	are_bodies_moving = false
