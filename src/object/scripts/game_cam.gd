extends Camera2D

@export var dynamic_camera: bool = true

var _tween: Tween
var original_pos


func _ready() -> void:
	original_pos = position
	if dynamic_camera:
		PlayerInput.input_turn.connect(func(turn_to: float):
			if _tween:
				_tween.kill()
			
			var dur := 0.5
			var move_to: float = sign(turn_to) * 2.0
			position = original_pos
			
			_tween = create_tween()
			_tween.tween_property(self,"position:x",move_to+original_pos.x,dur/4.0)
			_tween.tween_property(self,"position:x",original_pos.x,dur/2.0)
			)
