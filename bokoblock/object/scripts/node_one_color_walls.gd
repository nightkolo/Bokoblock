extends Area2D
class_name OneColorWalls

signal has_been_entered()
signal incorrect_entered()

@export var what_im_looking_for: GameUtil.BokoColor = GameUtil.BokoColor.AQUA
@export var emit_sfx: bool = true

@onready var child_walls: Array[Node] = get_children()

var bodies_entered: Array[Bokobody]

var _previous_area_count: int


func _ready() -> void:
	_setup_node()
	
	has_been_entered.connect(func():
		if emit_sfx && !Audio.one_color_wall_enter.playing:
			Audio.one_color_wall_enter.play()
		)
		
	incorrect_entered.connect(func():
		if emit_sfx && !Audio.one_color_wall_hit.playing:
			Audio.one_color_wall_hit.play()
		)
		
	#area_exited.connect(func(_area: Area2D):
		#pass
		#)


func _process(_delta: float) -> void:
	_check_areas()


func _check_areas() -> void:
	if get_overlapping_areas().size() != _previous_area_count:
		_on_areas_entered(get_overlapping_areas())
		_previous_area_count = get_overlapping_areas().size()


func _setup_node() -> void:
	for wall in child_walls:
		wall.node_sprites.modulate = Color(Color.WHITE, 0.9)
		wall.sprite_2d.self_modulate = GameUtil.set_boko_color(what_im_looking_for)
		wall.cross.self_modulate = GameUtil.set_boko_color(what_im_looking_for)


func _on_areas_entered(areas: Array[Area2D]) -> void:
	#print("")
	#print_debug(areas)
	#
	if areas.size() > 1:

		for area: Area2D in areas:
			if area is Bokoblock:
				
				var parent: Bokobody = (area as Bokoblock).parent_bokobody
				
				if (
					(area as Bokoblock).boko_color != what_im_looking_for &&
					!(parent in bodies_entered)
				):
					(area as Bokoblock).can_we_stop_moving_dad()
					incorrect_entered.emit()
					
					return
	
	for area: Area2D in areas:
		if area is Bokoblock:
			
			var parent: Bokobody = (area as Bokoblock).parent_bokobody
			
			if (area as Bokoblock).boko_color == what_im_looking_for:
				
				if !(parent in bodies_entered):
					bodies_entered.push_back(parent)
					
					parent.child_block_entered_one_col_wall.emit((area as Bokoblock))
					
					parent.is_one_way_wall = self
					parent.is_on_one_way_wall = true
					has_been_entered.emit()
				
				#print('')
				#print_debug(its_parent)
				#print_debug(bodies_entered)
				
			else:
				if !(parent in bodies_entered):
					
					(area as Bokoblock).can_we_stop_moving_dad()
					incorrect_entered.emit()
	
	
	
func _on_areas_exited(_areas: Array[Area2D]):
	pass
