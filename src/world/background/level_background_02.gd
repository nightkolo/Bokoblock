## Under construction
extends CanvasLayer
class_name Background02

@export var get_up: bool = true

@onready var texture: TextureRect = $TextureRect

var background_effect: GameUtil.BackgroundEffect

var parent_level_world: LevelWorld
var _background_set: bool = false


func _ready() -> void:
	if get_up && get_parent() is LevelWorld:
		parent_level_world = get_parent() as LevelWorld
	
	if parent_level_world:
		texture.self_modulate = parent_level_world.background_color
		
		if parent_level_world.randomize_background_effect:
			background_effect = GameUtil.BackgroundEffect.keys()[randi() % GameUtil.BackgroundEffect.size()]
		else:
			background_effect = parent_level_world.background_effect
	
	_background_set = true


func _process(delta: float) -> void:
	if _background_set:
		move_background(delta, background_effect)


func move_background(delta: float, effect: GameUtil.BackgroundEffect) -> void:
	match effect:
		
		GameUtil.BackgroundEffect.SCROLL:
			
			texture.position += delta * 10.0 * -Vector2.ONE
	
			if abs(texture.position.x) > 480.0:
				texture.position = Vector2.ZERO
