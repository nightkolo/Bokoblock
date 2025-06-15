## Player input
extends Node

signal input_turn(turn_to: float)
signal input_move(move_to: Vector2)
signal movement_input_made()

var last_input: GameLogic.TransformationType


func _unhandled_input(event: InputEvent) -> void:
	if GameMgr.current_menu == GameMgr.Menus.RUNTIME && !Trans.is_transitioning:
		
		if event.is_action_pressed("move_turn_left"):
			call_input_turn(-1.0)
			
		if event.is_action_pressed("move_turn_right"):
			call_input_turn(1.0)
		
		if event.is_action_pressed("move_right"):
			call_input_move(Vector2.RIGHT)
			
		if event.is_action_pressed("move_left"):
			call_input_move(Vector2.LEFT)
			
		if event.is_action_pressed("move_up"):
			call_input_move(Vector2.UP)
			
		if event.is_action_pressed("move_down"):
			call_input_move(Vector2.DOWN)


func _input(event: InputEvent) -> void: # Added for main menu easter egg
	if GameMgr.current_menu == GameMgr.Menus.MENUS || GameMgr.current_menu == GameMgr.Menus.CREDITS:
		
		if event.is_action_pressed("move_turn_left"):
			call_input_turn(-1.0)
			
		if event.is_action_pressed("move_turn_right"):
			call_input_turn(1.0)
		
		if event.is_action_pressed("move_right"):
			call_input_move(Vector2.RIGHT)
			
		if event.is_action_pressed("move_left"):
			call_input_move(Vector2.LEFT)
			
		if event.is_action_pressed("move_up"):
			call_input_move(Vector2.UP)
			
		if event.is_action_pressed("move_down"):
			call_input_move(Vector2.DOWN)
	
	
func call_input_move(move_to: Vector2 = Vector2.ZERO) -> void:
	if !GameLogic.can_move(): 
		return
	
	last_input = GameLogic.TransformationType.MOVE
	
	movement_input_made.emit()
	input_move.emit(move_to.sign())
	GameLogic.bodies_moved.emit(move_to.sign())
	GameLogic.has_moved()


func call_input_turn(turn_to: float = 0.0) -> void:
	if !GameLogic.can_move(): 
		return
	
	last_input = GameLogic.TransformationType.TURN
	
	movement_input_made.emit()
	input_turn.emit(signf(turn_to))
	GameLogic.bodies_moved.emit(signf(turn_to))
	GameLogic.has_moved()
