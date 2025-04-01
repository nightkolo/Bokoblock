extends Node2D
class_name Endpoints
# TODO: change to Starpoints

@export var overwrite: bool = false ## @experimental
@export var what_theyre_happy_with: GameUtil.BokoColor

@onready var child_starpoints: Array[Node] = get_children()


func _ready() -> void:
	_setup()


func _setup() -> void:
	if !overwrite:
		return
	
	for star: Starpoint in child_starpoints:
		if star is Starpoint:
			star.what_im_happy_with = what_theyre_happy_with
			star.setup_node()
			
		else:
			push_error(str(star) + " is not a Starpoint at " + str(self))
			break
			
	
