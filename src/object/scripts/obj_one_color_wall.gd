class_name OneColorWall
extends CollisionShape2D

@onready var node_sprites: Node2D = $Sprite

var parent_one_color_walls: OneColorWalls


func _ready() -> void:
	_setup()
	
	
func _setup() -> void:
	if get_parent() is OneColorWalls:
		parent_one_color_walls = get_parent() as OneColorWalls
	
	if parent_one_color_walls:
		node_sprites.modulate = GameUtil.set_boko_color(parent_one_color_walls.im_looking_for)
