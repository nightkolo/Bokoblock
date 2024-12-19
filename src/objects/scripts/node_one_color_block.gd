## Under contruction
extends Area2D
class_name OneColorBlock

# TODO: Better collision layers management needed.

@export var im_looking_for: GameLogic.BokoColor
@export_group("Objects to Assign")
@export var nodes_sprite: Node2D

var can_pass_through: bool = false
var blocks_parent_bokobody: Bokobody ## @experimental

var _previous_area_count: int


func _ready() -> void:
	_setup_node()
	
	GameLogic.bokobodies_stopped.connect(check_state)
	
	area_exited.connect(func(area: Area2D):
		if can_pass_through && area is Bokoblock && get_overlapping_areas().is_empty():
			(area as Bokoblock).anim_exited_one_color_block()
			print_debug("stopped")
		)


var _tween_hit: Tween


func anim_hit() -> void:
	pass
	#if _tween_hit:
		#_tween_hit.kill()
	#for node_sprite: Node2D in nodes_sprite.get_children():
		#if node_sprite.get_node_or_null("Cross"):
			#var sprite_cross: Sprite2D = node_sprite.get_node_or_null("Cross")
			#
			#
			#
			#_tween_hit.tween_property()


func _setup_node() -> void:
	collision_layer = 0
	collision_mask = 1

	if nodes_sprite:
		if nodes_sprite.get_children().is_empty():
			return
			
		for node_sprite: Node2D in nodes_sprite.get_children():
			node_sprite.modulate = GameLogic.set_boko_color(im_looking_for)


func _process(_delta: float) -> void:
	_check_areas()


func check_state() -> void:
	if !can_pass_through:
		return
		
	var areas := get_overlapping_areas()
	
	can_pass_through = are_all_elements_same_class(areas, "Bokoblock")


func bokoblocks_area_entered(areas: Array[Area2D]) -> void:
	# TODO: param 'areas' very much assumes it is an Array[Bokoblock], might cause runtime errors, though error handling comes to save the day. Refactor perhaps.
	# TODO: the namings and readable are terrible
	
	if areas.size() != 1: # Returns func if Array size is 0, or greater than 1. Only one block can register.
		if !can_pass_through && !areas.is_empty():
			if areas[0] is Bokoblock:
				(areas[0] as Bokoblock).can_we_stop_moving_dad()
				
				var child_blocks := (areas[0] as Bokoblock).parent_bokobody.child_blocks
				
				for block: Bokoblock in child_blocks:
					block.anim_hit_block()
					
				
		return
	
	if areas[0] is Bokoblock:
		
		if (areas[0] as Bokoblock).boko_color == im_looking_for && !can_pass_through:
			can_pass_through = true
			(areas[0] as Bokoblock).anim_entered_one_color_block()
			
		elif !can_pass_through:
			anim_hit()
			(areas[0] as Bokoblock).anim_hit_block()
			(areas[0] as Bokoblock).can_we_stop_moving_dad() # maybe i need to think about this method name


func are_all_elements_same_class(array: Array[Area2D], specified_class: String) -> bool:
	if array.size() == 0:
		return false
		
	for element: Area2D in array:
		if element.is_class(specified_class):
			return false
			
	return true


## @experimental
func greater_than_1_block(areas: Array[Area2D]) -> bool:
	var value := false
	
	if !can_pass_through && !areas.is_empty():
		value = areas[0] is Bokoblock
	
	return value


func _check_areas() -> void:
	if get_overlapping_areas().size() != _previous_area_count:
		bokoblocks_area_entered(get_overlapping_areas())
		_previous_area_count = get_overlapping_areas().size()
		
		
