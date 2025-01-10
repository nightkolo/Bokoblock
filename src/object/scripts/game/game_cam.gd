## Under construction
extends Camera2D
class_name BokosCamera

@export var dynamic_camera: bool = false ## @experimental
@export var shake_strength: float = 3.0
@export var shake_duration: float = 0.5

var _tween: Tween
var original_pos: Vector2


func _ready() -> void:
	original_pos = position
	
	#position = get_viewport_rect().size / 2.0
	
	if dynamic_camera:
		PlayerInput.input_turn.connect(func(turn_to: float):
			if _tween:
				_tween.kill()
			
			var move_to: float = sign(turn_to) * shake_strength
			position = original_pos
			
			_tween = create_tween()
			_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			_tween.tween_property(self,"position:x",move_to+original_pos.x,shake_duration/4.0)
			_tween.tween_property(self,"position:x",original_pos.x,shake_duration/2.0)
			)


## @experimental
func shake_camera(turn_to: float) -> void:
	if _tween:
		_tween.kill()
	
	var dur := 0.5
	var move_to: float = sign(turn_to) * 2.0
	position = original_pos
	
	_tween = create_tween()
	_tween.tween_property(self,"position:x",move_to+original_pos.x,dur/4.0)
	_tween.tween_property(self,"position:x",original_pos.x,dur/2.0)
