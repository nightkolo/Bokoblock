extends Sprite2D


func _ready() -> void:
	visible = true


func _process(delta: float) -> void:
	position += delta * 10.0 * -Vector2.ONE
	
	if abs(position.x) > 480.0:
		position = Vector2.ZERO
