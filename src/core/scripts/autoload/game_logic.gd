extends Node

## Emitted when bodies make a transformation.
signal bokobodies_moved(transformed_to: Variant)
## Emitted when a bokobody stops
signal bokobody_stopped(is_body: Bokobody)
# Emited when all bodies stopped transformation
signal bokobodies_stopped()
## Emitted when game won.
signal stage_won()

enum TranformationType {MOVE = 0, TURN = 1, UNDO = 99} ## @experimental
enum BokoPose {NORMAL = 0, THINKING = 1, NO_WORRY = 2, HAPPY = 3, WINK = 4} ## @deprecated: TODO: use GameUtil.BokoCharacterPose

var has_won: bool = false
var win_checked: bool = true
var are_bodies_moving: bool = false

var _bodies_stopped: int = 0
#var _is_game_logic_resetting: bool = false


func _ready() -> void:
	bokobody_stopped.connect(check_if_all_bodies_stopped)
	bokobodies_stopped.connect(check_win)
	
	GameMgr.game_reset.connect(_reset_game_logic)
	
	stage_won.connect(func():
		GameMgr.game_just_ended.emit()
		)


func check_if_all_bodies_stopped(_is_body: Bokobody) -> void:
	if GameMgr.current_bodies.is_empty():
		return
	
	var num_of_bodies := GameMgr.current_bodies.size()
	
	if are_bodies_moving:
		_bodies_stopped += 1
		
		if _bodies_stopped == num_of_bodies:
			check_if_body_moving(num_of_bodies)
			_bodies_stopped = 0
		

func check_if_body_moving(num_of_bodies: int = GameMgr.current_bodies.size()) -> void:
	if GameMgr.current_bodies.is_empty():
		return
	
	var bodies_stopped: int = 0
	
	for body: Bokobody in GameMgr.current_bodies:
		if !body.is_transforming():
			bodies_stopped += 1
	
	are_bodies_moving = bodies_stopped != num_of_bodies
	
	if !are_bodies_moving:
		bokobodies_stopped.emit()


func check_win() -> void:
	if GameMgr.current_endpoints.is_empty():
		win_checked = true
		return
	
	var num_of_ends: int = GameMgr.current_endpoints.size()
	var ends_satisfied: int = 0
	
	for endpoint: Endpoint in GameMgr.current_endpoints:
		var is_happy := endpoint.check_satisfaction()
		
		if is_happy:
			ends_satisfied += 1
	
	has_won = ends_satisfied == num_of_ends
	
	if has_won:
		win_stage()
		
	win_checked = true


func win_stage() -> void:
	stage_won.emit()
	print("Game over.")


func can_move() -> bool:
	return !are_bodies_moving && win_checked && !has_won


func self_detruct() -> void:
	_reset_game_logic()


func _reset_game_logic() -> void:
	has_won = false
	win_checked = true
	are_bodies_moving = false


func has_moved() -> void:
	are_bodies_moving = true
	win_checked = false
