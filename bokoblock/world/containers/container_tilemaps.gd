## Under construction
extends Node2D
class_name TileMaps

@export var apply_parent_values: bool = true

@onready var child_tilemaps: Array[Node] = get_children()

var parent_level_world: StageWorld
var checkerboard_color: Color = Color.WHITE
var show_collision_tilemap: bool = false

# A 1 0.77 0.77 0.8
# A 2 0.8 0.8 0.7
# Area 3 0.8, 0.7, 0.7

func _ready() -> void:
	_setup_nodes()
	

func _setup_nodes() -> void:
	self.scale = Vector2.ONE / 2.0
	
	if apply_parent_values && get_parent() is StageWorld:
		parent_level_world = get_parent() as StageWorld
	
	if parent_level_world && child_tilemaps.size() == 3:
		if !parent_level_world.apply_modifications:
			return
		
		(child_tilemaps[0] as TileMapLayer).visible = parent_level_world.show_collision_tilemap
		(child_tilemaps[1] as TileMapLayer).visible = !parent_level_world.show_collision_tilemap
		(child_tilemaps[2] as TileMapLayer).visible = !parent_level_world.show_collision_tilemap
		
		
		(child_tilemaps[1] as TileMapLayer).self_modulate = parent_level_world.checkerboard_color
		(child_tilemaps[1] as TileMapLayer).light_mask = 2
		
		(child_tilemaps[2] as TileMapLayer).self_modulate = Color(Color.WHITE,0.9)
