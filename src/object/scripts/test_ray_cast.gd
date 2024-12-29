extends RayCast2D


func _process(_delta: float) -> void:
	print(get_collider() is TileMapLayer)
