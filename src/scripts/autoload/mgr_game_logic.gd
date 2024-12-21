extends Node

## Emitted when bodies make a transformation.
signal bokobodies_moved(transformed_to: Variant)
## Emitted when a bokobody stops
signal bokobody_stopped(is_body: Bokobody)
# Emited when all bodies stopped transformation
signal bokobodies_stopped()
## Emitted when game won.
signal game_end()

enum TranformationType {MOVE = 0, TURN = 1, UNDO = 99} ## @experimental
enum BokoColor {AQUA = 0, RED = 1, BLUE = 2, YELLOW = 3, GREEN = 4, PINK = 5, GREY = 99}
enum BokoPose {NORMAL = 0, THINKING = 1, NO_WORRY = 2, HAPPY = 3, WINK = 4} ## @experimental

var has_won: bool = false
var win_checked: bool = true
var are_bodies_moving: bool = false

var number_of_bodies: int
var current_level: Level
var current_bodies: Array[Bokobody]
var current_endpoints: Array[Endpoint]

var _bodies_stopped: int = 0
var _is_game_logic_resetting: bool = false


func _ready() -> void:
	bokobody_stopped.connect(check_if_all_bodies_stopped)
	bokobodies_stopped.connect(check_win)
	
	await get_tree().create_timer(0.1).timeout
	number_of_bodies = current_bodies.size()


func check_if_all_bodies_stopped(_is_body: Bokobody) -> void:
	#var b := is_body
	
	if current_bodies.is_empty():
		return
	
	var num_of_bodies := current_bodies.size()
	
	if are_bodies_moving:
		_bodies_stopped += 1
		
		if _bodies_stopped == num_of_bodies:
			check_if_body_moving(num_of_bodies)
			_bodies_stopped = 0
		

func check_if_body_moving(num_of_bodies: int = current_bodies.size()) -> void:
	if current_bodies.is_empty():
		return
	
	var bodies_stopped: int = 0
	
	for body: Bokobody in current_bodies:
		if !body.is_transforming():
			bodies_stopped += 1
	
	are_bodies_moving = bodies_stopped != num_of_bodies
	
	if !are_bodies_moving:
		bokobodies_stopped.emit()


func check_win() -> void:
	if current_endpoints.is_empty():
		win_checked = true
		return
	
	var num_of_ends: int = current_endpoints.size()
	var ends_satisfied: int = 0
	
	for endpoint: Endpoint in current_endpoints:
		var is_happy := endpoint.check_satisfaction()
		
		if is_happy:
			ends_satisfied += 1
	
	has_won = ends_satisfied == num_of_ends
	
	if has_won:
		win_game()
		
	win_checked = true


func win_game() -> void:
	game_end.emit()
	print("Game over.")


func can_move() -> bool:
	return !are_bodies_moving && win_checked && !has_won


func set_boko_color(is_bokocolor: BokoColor) -> Color:
	var col: Color
	
	match is_bokocolor:
		
		BokoColor.AQUA:
			col = Color(1.0,0.77,1.0) # I lied, cry about it.
			
		BokoColor.RED:
			col = Color(Color(1.0,0.5,0.5))
		
		BokoColor.BLUE:
			col = Color(Color(0.5,0.5,1.0))
			
		BokoColor.YELLOW:
			col = Color(Color(1.0,1.0,0.5))
			
		BokoColor.GREEN:
			col = Color(Color.GREEN)
			
		BokoColor.PINK:
			col = Color(Color.PINK)
			
		BokoColor.GREY:
			col = Color(Color.GRAY)
			
	return col


func reset_game_logic() -> void:
	if !_is_game_logic_resetting:
		_is_game_logic_resetting = true
		current_bodies = []
		current_endpoints = []
		has_won = false
		win_checked = true
		are_bodies_moving = false
		number_of_bodies = 0
		
		await get_tree().create_timer(0.1).timeout
		number_of_bodies = current_bodies.size()
		_is_game_logic_resetting = false


func has_moved() -> void:
	are_bodies_moving = true
	win_checked = false
