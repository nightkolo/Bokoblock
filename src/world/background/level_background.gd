## @deprecated: Go to [url]res://world/background/stage_background.gd[\url]
extends Sprite2D
class_name BackgroundTest

@export var get_up: bool = true

var background_effect: GameUtil.BackgroundEffect

var parent_level_world: StageWorld
var _background_set: bool = false


func _ready() -> void:
	if get_up && get_parent() is StageWorld:
		parent_level_world = get_parent() as StageWorld
	
	if parent_level_world:
		self_modulate = parent_level_world.background_color
		
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
			
			position += delta * 10.0 * -Vector2.ONE
	
			if abs(position.x) > 480.0:
				position = Vector2.ZERO
