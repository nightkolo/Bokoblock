## Under construction
extends Node2D
class_name TileMaps

@export var get_up: bool = true

@onready var child_tilemaps: Array[Node] = get_children()

var parent_level_world: LevelWorld
var checkerboard_color: Color = Color.WHITE
var show_collision_tilemap: bool = false


func _ready() -> void:
	if get_up && get_parent() is LevelWorld:
		parent_level_world = get_parent() as LevelWorld
	
	if parent_level_world && child_tilemaps.size() == 3:
		(child_tilemaps[0] as TileMapLayer).visible = parent_level_world.show_collision_tilemap
		
		(child_tilemaps[1] as TileMapLayer).self_modulate = parent_level_world.checkerboard_color
		
		(child_tilemaps[2] as TileMapLayer).self_modulate = Color(Color.WHITE,0.9)
