extends Sprite2D


func _process(_delta: float) -> void:
	#position = get_global_mouse_position()
	position = (get_global_mouse_position() + ((Vector2.ONE * GameUtil.TILE_SIZE) / 2.0)).snapped(
		(Vector2.ONE * GameUtil.TILE_SIZE)
		)
