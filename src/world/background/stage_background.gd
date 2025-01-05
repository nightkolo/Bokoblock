## Under construction
extends CanvasLayer
class_name Background

@export var apply_parent_values: bool = true
@export var background_effect: GameUtil.BackgroundEffect
@export_range(0.0, 2.0, 0.05, "or_greater", "or_less") var effect_lengths_multiplier: float = 1.0 ## @experimental

@onready var texture_bg: TextureRect = $Texture/TextureRect
@onready var texture_node: Node2D = $Texture

var parent_level_world: StageWorld

var _tween_a: Tween
var _tween_b: Tween
var _background_effect: GameUtil.BackgroundEffect
var _effect_lengths_multiplier: float
var _process_bg_fx: bool = false:
	get:
		return _process_bg_fx
	set(value):
		set_process(value)
		_process_bg_fx = value


func _ready() -> void:
	set_process(false)
	_setup_node()
	

func _setup_node() -> void:
	#print(GameUtil.BackgroundEffect.values())
	
	if (apply_parent_values && get_parent() is StageWorld):
		parent_level_world = get_parent() as StageWorld
	
	elif !apply_parent_values:
		_background_effect = background_effect
		_effect_lengths_multiplier = effect_lengths_multiplier
		set_background_effect(_background_effect)
		return
	
	if parent_level_world:
		if !parent_level_world.apply_modifications:
			return
			
		texture_bg.self_modulate = parent_level_world.background_color
		_effect_lengths_multiplier = parent_level_world.effect_lengths_multiplier
		
		if parent_level_world.randomize_background_effect:
			_background_effect = GameUtil.BackgroundEffect.values()[randi() % GameUtil.BackgroundEffect.size()]
		else:
			_background_effect = parent_level_world.background_effect
		
		#print_debug(_background_effect)
		set_background_effect(_background_effect)
		return
	
	set_background_effect(_background_effect)


func _process(delta: float) -> void:
	if _process_bg_fx:
		_process_background_effect(delta, _background_effect)


func set_background_effect(effect: GameUtil.BackgroundEffect) -> void:
	match effect:
			
		GameUtil.BackgroundEffect.ZOOM:
			_process_bg_fx = false
			
			_center_nodes()
			texture_node.rotation = PI / 4.0 
			# to be honest, i use "rotation" instead of "rotation_degrees" cause it looks fancier
			
			if _tween_a:
				_tween_a.kill()
			
			_tween_a = create_tween().set_loops()
			_tween_a.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

			_tween_a.tween_property(texture_node,"scale",Vector2.ONE/1.5,7.0*_effect_lengths_multiplier)
			_tween_a.tween_property(texture_node,"scale",Vector2.ONE*1.5,7.0*_effect_lengths_multiplier)
		
		GameUtil.BackgroundEffect.SKEW:
			_process_bg_fx = false
			
			_center_nodes()
			texture_node.rotation = PI / 4.0
			
			if _tween_a:
				_tween_a.kill()
			if _tween_b:
				_tween_b.kill()
			
			_tween_a = create_tween().set_loops()
			_tween_b = create_tween().set_loops()
			_tween_a.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			_tween_b.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			
			_tween_a.tween_property(texture_node,"skew",deg_to_rad(-25.0),4.0*_effect_lengths_multiplier)
			_tween_a.tween_property(texture_node,"skew",deg_to_rad(25.0),4.0*_effect_lengths_multiplier)

			_tween_b.tween_property(texture_node,"rotation",deg_to_rad(-45.0),13.0*_effect_lengths_multiplier)
			_tween_b.tween_property(texture_node,"rotation",deg_to_rad(45.0),13.0*_effect_lengths_multiplier)
		
		GameUtil.BackgroundEffect.SCROLL:
			texture_bg.position = Vector2.ZERO
			texture_node.position = Vector2.ZERO
			
			_process_bg_fx = true
		
		GameUtil.BackgroundEffect.ROTATE:
			_center_nodes()
			
			_process_bg_fx = true
			
		_:
			pass


func _center_nodes() -> void:
	texture_bg.position = -GameUtil.GAME_SCREEN_SIZE
	texture_node.position = GameUtil.GAME_SCREEN_SIZE / 2.0


func _process_background_effect(delta: float, effect: GameUtil.BackgroundEffect) -> void:
	match effect:
		GameUtil.BackgroundEffect.SCROLL:
			texture_bg.position += delta * 10.0 * -Vector2.ONE * _effect_lengths_multiplier
	
			if abs(texture_bg.position.x) > 480.0:
				texture_bg.position = Vector2.ZERO
		
		GameUtil.BackgroundEffect.ROTATE:
			texture_node.rotation += delta * (PI / 24.0) * _effect_lengths_multiplier
		
		GameUtil.BackgroundEffect.SKEW:
			pass
			
		GameUtil.BackgroundEffect.ZOOM:
			pass
			
		_:
			pass
