extends Node

signal input_turn(turn_to: float)
signal input_move(move_to: Vector2)
signal movement_input_made()
#signal input_undo() ## @deprecated

var last_input: GameLogic.TransformationType


func _unhandled_input(event: InputEvent) -> void:
	if GameMgr.current_menu == GameMgr.Menus.RUNTIME && !Trans.is_transitioning:
		
		if event.is_action_pressed("move_turn_left"):
			_call_input_turn(-1.0)
			
		if event.is_action_pressed("move_turn_right"):
			_call_input_turn(1.0)
		
		if event.is_action_pressed("move_right"):
			_call_input_move(Vector2.RIGHT)
			
		if event.is_action_pressed("move_left"):
			_call_input_move(Vector2.LEFT)
			
		if event.is_action_pressed("move_up"):
			_call_input_move(Vector2.UP)
		
		if event.is_action_pressed("move_down"):
			_call_input_move(Vector2.DOWN)
		

# func _call_input_undo():
# 	if !GameLogic.can_move():
# 		return
	
# 	last_input = GameLogic.TransformationType.UNDO
	
# 	input_undo.emit()
# 	GameLogic.bodies_moved.emit(false)
# 	GameLogic.has_moved()
	
	
func _call_input_move(move_to: Vector2 = Vector2.ZERO) -> void:
	if !GameLogic.can_move(): 
		return
	
	last_input = GameLogic.TransformationType.MOVE
	
	movement_input_made.emit()
	input_move.emit(move_to.sign())
	GameLogic.bodies_moved.emit(move_to.sign())
	GameLogic.has_moved()


func _call_input_turn(turn_to: float = 0.0) -> void:
	if !GameLogic.can_move(): 
		return
	
	last_input = GameLogic.TransformationType.TURN
	
	movement_input_made.emit()
	input_turn.emit(signf(turn_to))
	GameLogic.bodies_moved.emit(signf(turn_to))
	GameLogic.has_moved()
