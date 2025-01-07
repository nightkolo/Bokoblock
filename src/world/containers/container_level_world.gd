extends Node2D
class_name StageWorld

enum StageWorldBGColorPreset {
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

@export var randomize_background_effect: bool = false
@export var background_effect: GameUtil.BackgroundEffect = GameUtil.BackgroundEffect.SCROLL ## @experimental
@export var background_color: StageWorldBGColorPreset
@export var custom_background_color: Color = Color(Color.GRAY, 1.0)
@export var checkerboard_color: Color = Color(Color.WHITE / 1.3, 1.0)
@export_group("Modify")
@export var apply_modifications: bool = true
@export_range(0.0, 2.0, 0.05, "or_greater") var effect_lengths_multiplier: float = 1.0
@export var show_collision_tilemap: bool = false


static func set_background_color(is_preset: StageWorldBGColorPreset) -> Color:
	var col: Color
	
	match is_preset:
		StageWorldBGColorPreset.RANDOMIZE:
			col = set_background_color(StageWorld.StageWorldBGColorPreset.values()[randi()%StageWorld.StageWorldBGColorPreset.size()])
		
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


func _ready() -> void:
	pass
