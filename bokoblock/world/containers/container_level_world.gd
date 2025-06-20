extends Node2D
class_name BoardWorld

enum StageWorldBGColorPreset { ## @deprecated
	BLUE = 0,
	DARK_BLUE = 1,
	PINK = 2,
	RED = 3,
	YELLOW = 4,
	GREEN = 5,
	AQUA = 6,
	GREY = 7,
	RANDOMIZE = 101,
	CUSTOM = 102
}
enum BGCheckerboard {
	ONE = 0,
	TWO = 1
}
enum BGPalette {
	Palette_1 = 0,
	Palette_2 = 1,
	Palette_3 = 2,
	Palette_4 = 3,
}

@export var apply_modifications: bool = true
@export var checkerboard: BGCheckerboard
@export var color_pallete: BGPalette
@export_category("Objects to Assign")
@export var auto_assign: bool = true
@export var background: Background
@export var tile_maps: TileMaps
@export_category("Debug")
@export var show_collision_tilemap: bool = false


func _ready() -> void:
	if !apply_modifications:
		return
		
	if auto_assign:
		for node: Node in get_children():
			if node is Background:
				background = node
				continue
			
			if node is TileMaps:
				tile_maps = node
	
	if background:
		background.texture_bg.self_modulate = get_checkerboard_bg_color()
	
	if tile_maps:
		if tile_maps.child_tilemaps.size() != 3:
			push_error("Tile Map nodes != 3. Cannot apply modifications.")
			return
			
		for tile: TileMapLayer in tile_maps.child_tilemaps:
			if !(tile is TileMapLayer):
				push_error(str(tile) + "is not a TileMapLayer. Cannot apply modifications.")
				return
			
		(tile_maps.child_tilemaps[0] as TileMapLayer).visible = show_collision_tilemap
		(tile_maps.child_tilemaps[1] as TileMapLayer).visible = !show_collision_tilemap
		(tile_maps.child_tilemaps[2] as TileMapLayer).visible = !show_collision_tilemap
		
		(tile_maps.child_tilemaps[1] as TileMapLayer).self_modulate = get_checkerboard_checkerboard_color()
		(tile_maps.child_tilemaps[1] as TileMapLayer).light_mask = 2
		
		(tile_maps.child_tilemaps[2] as TileMapLayer).self_modulate = Color(Color.WHITE,0.9)


func get_checkerboard_checkerboard_color(is_preset: BGCheckerboard = checkerboard) -> Color:
	var col: Color
	
	match is_preset:
		BGCheckerboard.ONE:
			col = Color(Color.WHITE / 1.3, 1.0)
			
		BGCheckerboard.TWO:
			col = Color(Color.WHITE / 1.6, 1.0)
	
	return col


func get_checkerboard_bg_color(is_preset: BGCheckerboard = checkerboard) -> Color:
	var col: Color
	
	match is_preset:
		BGCheckerboard.ONE:
			
			match color_pallete:
				
				BGPalette.Palette_1:
					col = Color(0.37, 0.37, 0.5)
					
				BGPalette.Palette_2:
					col = Color(0.3, 0.3, 0.5)
					
				BGPalette.Palette_3:
					col = Color(0.35, 0.35, 0.45)
					
				BGPalette.Palette_4:
					col = Color(0.32, 0.32, 0.4)
			
		BGCheckerboard.TWO:
			match color_pallete:
				
				BGPalette.Palette_1:
					col = Color(0.6, 0.3, 0.35)
					
				BGPalette.Palette_2:
					col = Color(0.6, 0.25, 0.25)
					
				BGPalette.Palette_3:
					col = Color(0.6, 0.4, 0.4)
					
				BGPalette.Palette_4:
					col = Color(0.5, 0.32, 0.4)
	
	return col


## @deprecated
static func set_background_color(is_preset: StageWorldBGColorPreset) -> Color:
	var col: Color
	
	match is_preset:
		StageWorldBGColorPreset.RANDOMIZE:
			col = set_background_color(BoardWorld.StageWorldBGColorPreset.values()[randi()%BoardWorld.StageWorldBGColorPreset.size()])
		
		StageWorldBGColorPreset.CUSTOM:
			pass
			
		StageWorldBGColorPreset.BLUE:
			col = Color(0.6,0.6,0.9)
		
		StageWorldBGColorPreset.DARK_BLUE:
			col = Color(0.37,0.37,0.5)
		
		StageWorldBGColorPreset.PINK:
			col = Color(0.9,0.5,0.9)
		
		StageWorldBGColorPreset.RED:
			col = Color(0.9,0.6,0.6)
		
		StageWorldBGColorPreset.YELLOW:
			col = Color(0.9,0.9,0.5)
		
		StageWorldBGColorPreset.GREEN:
			col = Color(0.6,0.9,0.6)
		
		StageWorldBGColorPreset.AQUA:
			col = Color(0.7,0.7,0.8)
		
		StageWorldBGColorPreset.GREY:
			col = Color(Color.GRAY)

	return col
