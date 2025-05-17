## @experimental
## Under contruction
extends Area2D
class_name OneColorWalls1

# TODO: Haven't tested two Bokoblock interacting
# TODO: Better collision layers management needed.

@export var im_looking_for: GameUtil.BokoColor

var can_pass_through: bool = false
var blocks_parent_bokobody: Bokobody ## @experimental

var _previous_area_count: int
@warning_ignore("unused_private_class_variable")
var _tween_hit: Tween


func _ready() -> void:
	_setup_node()
	
	GameLogic.bodies_stopped.connect(check_state)
	
	area_exited.connect(bokoblocks_area_exited)
	
	#await get_tree().create_timer(0.1).timeout
	#if GameMgr.current_stage:
		#GameMgr.current_stage.allow_undoing = false
	

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
	#print(get_overlapping_areas())
	
	if !can_pass_through:
		return
		
	var areas := get_overlapping_areas()
	
	can_pass_through = _are_all_areas_bokoblocks(areas)


func bokoblocks_area_entered(areas: Array[Area2D]) -> void:
	#print(areas)
	
	if areas.size() != 1:
		if _is_more_than_1_block(areas):
		
			(areas[0] as Bokoblock).can_we_stop_moving_dad()
			
			var child_blocks := (areas[0] as Bokoblock).parent_bokobody.child_blocks
			
			for block: Bokoblock in child_blocks:
				block.animator.anim_hit_block(Vector2.ZERO)
				
		return
	
	if areas[0] is Bokoblock:
		
		if (areas[0] as Bokoblock).boko_color == im_looking_for && !can_pass_through:
			can_pass_through = true
			(areas[0] as Bokoblock).animator.anim_entered_one_color_wall()
			
		elif !can_pass_through:
			anim_hit()
			(areas[0] as Bokoblock).animator.anim_hit_block(Vector2.ZERO)
			(areas[0] as Bokoblock).can_we_stop_moving_dad() # maybe i need to think about this method name


func bokoblocks_area_exited(area: Area2D) -> void:
	if can_pass_through && area is Bokoblock && get_overlapping_areas().is_empty():
		(area as Bokoblock).animator.anim_exited_one_color_wall()



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
