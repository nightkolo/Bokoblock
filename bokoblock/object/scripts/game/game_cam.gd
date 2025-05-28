extends Camera2D
class_name BokosCamera

@export var dynamic_camera: bool = false
@export var shake_strength: float = 6.0
@export var shake_duration: float = 0.5

var original_pos: Vector2

var _tween: Tween

func _ready() -> void:
	original_pos = position
	
	if dynamic_camera:
		PlayerInput.input_turn.connect(shake_camera)


func shake_camera(turn_to: float) -> void:
	if _tween:
		_tween.kill()
	
	var move_to: float = signf(turn_to) * shake_strength
	position = original_pos
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self,"position:x",move_to+original_pos.x,shake_duration/4.0)
	_tween.tween_property(self,"position:x",original_pos.x,shake_duration/2.0)
