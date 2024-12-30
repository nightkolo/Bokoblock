extends Node2D
class_name LevelWorld

@export var randomize_background_effect: bool = false
@export var background_effect: GameUtil.BackgroundEffect = 0 ## @experimental
@export var background_color: Color = Color.WHITE
@export var checkerboard_color: Color = Color.WHITE
@export_group("Modify")
@export var apply_modification: bool = true
@export var show_collision_tilemap: bool = false

@onready var world_nodes: Array[Node] = get_children() ## @deprecated


func _ready() -> void:
	pass
