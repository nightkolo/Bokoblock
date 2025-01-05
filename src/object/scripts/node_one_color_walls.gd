## @experimental
## Under contruction
extends Area2D
class_name OneColorWalls

# I don't wanna look at this damn code again...
# one thing i'm confused by is
# how the hell is this unreadable ass code bug-free and works perfectly.
# what the heck was i writing

# TODO: Haven't tested two Bokoblock interacting
# TODO: Better collision layers management needed.

@export var im_looking_for: GameUtil.BokoColor

var can_pass_through: bool = false
var blocks_parent_bokobody: Bokobody ## @experimental

var _previous_area_count: int
var _tween_hit: Tween


func _ready() -> void:
	_setup_node()
	
	GameLogic.bokobodies_stopped.connect(check_state)
	
	area_exited.connect(bokoblocks_area_exited)


func _process(_delta: float) -> void:
	_check_areas()


func _setup_node() -> void:
	collision_layer = 0
	collision_mask = 1


func _check_areas() -> void:
	if get_overlapping_areas().size() != _previous_area_count:
		bokoblocks_area_entered(get_overlapping_areas())
		_previous_area_count = get_overlapping_areas().size()


func check_state() -> void:
	if !can_pass_through:
		return
		
	var areas := get_overlapping_areas()
	
	can_pass_through = _are_all_areas_bokoblocks(areas)


func bokoblocks_area_entered(areas: Array[Area2D]) -> void:
	if areas.size() != 1:
		if _is_more_than_1_block(areas):
		
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


func bokoblocks_area_exited(area: Area2D) -> void:
	if can_pass_through && area is Bokoblock && get_overlapping_areas().is_empty():
		(area as Bokoblock).anim_exited_one_color_block()


func anim_hit() -> void:
	pass


func _are_all_areas_bokoblocks(array: Array[Area2D]) -> bool:
	if array.size() == 0:
		return false
		
	for area: Area2D in array:
		if area.is_class("Bokoblock"):
			return false
			
	return true


func _is_more_than_1_block(areas: Array[Area2D]) -> bool:
	var value := false
	
	if !can_pass_through && areas.size() > 1: # if !can_pass_through && !areas.is_empty():
		value = areas[0] is Bokoblock
	
	return value
