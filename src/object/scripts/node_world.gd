extends Node2D
class_name LevelWorld

@export var apply_modification: bool = true

@onready var world_nodes: Array[Node] = get_children()


func _ready() -> void:
	# TODO: Use @export
	
	if apply_modification && _is_correct_order():
		(world_nodes[1] as TileMapLayer).visible = false
		
		(world_nodes[2] as TileMapLayer).self_modulate = Color(0.85,0.85,0.85)
		
		(world_nodes[3] as TileMapLayer).self_modulate = Color(Color.WHITE,0.9)
		
		
func _is_correct_order() -> bool:
	return world_nodes[0] is Sprite2D && world_nodes[1] is TileMapLayer && world_nodes[2] is TileMapLayer && world_nodes[3] is TileMapLayer
