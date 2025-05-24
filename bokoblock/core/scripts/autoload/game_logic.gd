## Game logic.
extends Node

## Emitted when a [Bokobody] stops while [b]moving.
signal body_hit_move()
## Emitted when a [Bokobody] stops while [b]turning.
signal body_hit_turn()
## Emitted when all [Bokobody]s try to transform/make a move.
## [br][br][param transformed_to] is a dynamic variable returning the transformation value (A move, a turn).
signal bodies_moved(transformed_to)
## Emitted when a [Bokobody] stops,
## [br][br][param is_bokobody] returns that [Bokobody].
signal body_stopped(is_body: Bokobody)
## Emitted when all [Bokobody]s stop.
signal bodies_stopped()
## Emitted when a [Bokobody] enters a [Starpoint].
signal body_entered_starpoint()
## Emitted when a [Bokobody] exits a [Starpoint].
signal body_exited_starpoint()
## Emitted when the movement state of [Bokobody]s have been checked.
## [br][br]Helpful for checking [member we_have_made_a_move].
signal state_checked(have_moved: bool)
## Emitted when the stage is won.
signal stage_won()

signal bodies_undoed() ## @deprecated
signal bodies_stopped_making_move() ## @deprecated

enum WinCondition {
	MATCH_ALL_STARPOINTS = 0,
	MATCH_ALL_BLOCKS = 1
}
enum TransformationType {
	MOVE = 0,
	TURN = 1,
	UNDO = 99
}

static var win_condition: WinCondition

var has_won: bool = false
var win_checked: bool = true
var are_bodies_moving: bool = false
var is_block_on_starpoint: bool = false
var match_amount: int = 0

## Returns whether at least at least one [Bokobody] has transformed/made a move.
var we_have_made_a_move: bool ## @deprecated

var _bodies_stopped: int = 0
var _prev_positions: Array[Transform2D]


static func set_win_condition(win_cond: WinCondition) -> void:
	win_condition = win_cond


func _ready() -> void:
	#Engine.time_scale = 1.0/10.0
	
	body_stopped.connect(check_if_bodies_stopped)

	#bodies_stopped.connect(check_win)
	#bodies_stopped.connect(check_bodies)
	bodies_stopped.connect(_bodies_have_stopped)
	
	PlayerInput.movement_input_made.connect(_bodies_have_moved)
	
	GameMgr.game_reset.connect(_reset_game_logic)
	
	check_bodies()
	
	stage_won.connect(func():
		GameMgr.game_just_ended.emit()
		)
		
	await get_tree().create_timer(0.1).timeout
	check_win()


func check_bodies() -> void:
	await GameMgr.process_waittime()
	
	var stood_on_starpoint: bool = check_if_block_on_starpoint(GameMgr.current_blocks)
	
	if stood_on_starpoint && !is_block_on_starpoint:
		body_entered_starpoint.emit()
		is_block_on_starpoint = true
	elif !stood_on_starpoint && is_block_on_starpoint:
		body_exited_starpoint.emit()
		is_block_on_starpoint = false


func check_if_bodies_stopped(_is_body: Bokobody) -> void:
	var num_of_bodies: int = GameMgr.current_bodies.size()
	
	if num_of_bodies == 0:
		return
	
	_bodies_stopped += 1
	
	print(_bodies_stopped)
	print(num_of_bodies)
	print("")
	
	are_bodies_moving = _bodies_stopped != num_of_bodies
	
	if !are_bodies_moving:
		#if PlayerInput.last_input != TransformationType.UNDO:
			#bodies_stopped_making_move.emit()
			
		bodies_stopped.emit()
		_bodies_stopped = 0


func check_win() -> void:
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


func _bodies_have_moved() -> void:
	_prev_positions = []
		
	for body: Bokobody in GameMgr.current_bodies:
		_prev_positions.push_back(body.transform)


func _bodies_have_stopped() -> void:
	check_win()
	check_bodies()
	
	we_have_made_a_move = check_if_bodies_made_move()
	state_checked.emit(we_have_made_a_move)
	

## After the movement state has been checked,
## return [code]true[/code] if at least one [Bokobody] has transformed/made a move,
## [code]false[/code] if otherwise. 
## [br][br][b]Note:[/b] Used to be for the move counter and undo behaviour.
## But these features have been deprecated. The function just stands this way.
func check_if_bodies_made_move() -> bool:
	if GameMgr.current_bodies.is_empty():
		return false
	
	for i: int in range(GameMgr.current_bodies.size()):
		if _prev_positions[i] != GameMgr.current_bodies[i].transform:
			return true
		
	return false


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
	has_won = false
	win_checked = true
	are_bodies_moving = false
	is_block_on_starpoint = false
	match_amount = 0
	_bodies_stopped = 0
	_prev_positions = []
