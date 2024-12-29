extends Area2D
class_name Endpoint

@export var what_im_happy_with: GameLogic.BokoColor
@export var try_to_get_sprite: bool = true

var _sprite: Sprite2D


func _ready() -> void:
	GameLogic.current_endpoints.append(self)
	
	self.modulate = Color(Color.WHITE, 1.0)
	
	if try_to_get_sprite:
		_sprite = get_node_or_null("Sprite2D")
		
		if _sprite:
			_sprite.self_modulate = GameLogic.set_boko_color(what_im_happy_with)


func check_satisfaction() -> bool:
	var is_happy: bool
	var areas: Array[Area2D] = get_overlapping_areas()
	var is_what_im_looking_for: bool = areas.size() == 1 && areas[0] is Bokoblock
	
	if is_what_im_looking_for:
		is_happy = (areas[0] as Bokoblock).boko_color == what_im_happy_with
		
	return is_happy
