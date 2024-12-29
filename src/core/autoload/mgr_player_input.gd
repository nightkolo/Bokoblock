extends Node

## calls bokos to turn
signal input_turn(turn_to: float)
## calls bokos to move
signal input_move(move_to: Vector2)
## calls bokos to undo
signal input_undo()

enum TranformationType {MOVE = 0, TURN = 1, UNDO = 99} ## @experimental


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_reset"):
		GameLogic.reset_game_logic()
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("move_undo"):
		_call_input_undo()
	
	if event.is_action_pressed("move_turn_down"):
		_call_input_turn(-90.0)
		
	if event.is_action_pressed("move_turn_up"):
		_call_input_turn(90.0)
	
	if event.is_action_pressed("move_right"):
		_call_input_move(Vector2.RIGHT)
		
	if event.is_action_pressed("move_left"):
		_call_input_move(Vector2.LEFT)
		
	if event.is_action_pressed("move_up"):
		_call_input_move(Vector2.UP)
	
	if event.is_action_pressed("move_down"):
		_call_input_move(Vector2.DOWN)
		

func _call_input_undo():
	if GameLogic.can_move():
		input_undo.emit()
		GameLogic.bokobodies_moved.emit(false)
		GameLogic.has_moved()
	
	
func _call_input_move(move_to: Vector2 = Vector2.ZERO):
	if GameLogic.can_move(): 
		input_move.emit(move_to)
		GameLogic.bokobodies_moved.emit(move_to)
		GameLogic.has_moved()


func _call_input_turn(turn_to: float = 0.0):
	if GameLogic.can_move(): 
		input_turn.emit(turn_to)
		GameLogic.bokobodies_moved.emit(sign(turn_to))
		GameLogic.has_moved()
