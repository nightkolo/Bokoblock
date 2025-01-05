extends Node2D
class_name StageWorld

@export var randomize_background_effect: bool = false
@export var background_effect: GameUtil.BackgroundEffect = GameUtil.BackgroundEffect.SCROLL ## @experimental
@export var background_color: Color = Color(Color.WHITE / 2.0, 1.0)
@export var checkerboard_color: Color = Color(Color.WHITE / 1.5, 1.0)
@export_group("Modify")
@export var apply_modifications: bool = true
@export_range(0.0, 2.0, 0.05, "or_greater") var effect_lengths_multiplier: float = 1.0
@export var show_collision_tilemap: bool = false


func _ready() -> void:
	pass
