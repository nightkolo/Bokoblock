## @deprecated
class_name OneColorWall1
extends CollisionShape2D

@onready var node_sprites: Node2D = $Sprite
@onready var sprite_2d: Sprite2D = $Sprite/Sprite2D
@onready var cross: Sprite2D = $Sprite/Cross

var parent_one_color_walls: OneColorWalls1


func _ready() -> void:
	_setup()
	
	
func _setup() -> void:
	if get_parent() is OneColorWalls1:
		parent_one_color_walls = get_parent() as OneColorWalls1
	
	if parent_one_color_walls:
		node_sprites.modulate = Color(Color.WHITE, 0.9)
		sprite_2d.self_modulate = GameUtil.set_boko_color(parent_one_color_walls.im_looking_for)
		cross.self_modulate = GameUtil.set_boko_color(parent_one_color_walls.im_looking_for)
