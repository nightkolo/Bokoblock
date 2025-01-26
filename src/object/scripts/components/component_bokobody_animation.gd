extends Node
class_name BokobodyAnimationComponent

@onready var bokobody: Bokobody = get_parent() as Bokobody

var tween_one_col_wall: Tween


func _ready() -> void:
	if !(bokobody is Bokobody):
		push_error("%s is not a child of Bokobody." % str(self))
		return
	
	GameLogic.stage_won.connect(anim_complete)
	
	bokobody.child_block_entered_one_col_wall.connect(anim_blocks_entered_one_col_wall)
	bokobody.child_block_exited_one_col_wall.connect(anim_blocks_exited_one_col_wall)
	
	
func anim_blocks_entered_one_col_wall(is_block: Bokoblock) -> void:
	var dur := 1.0
	
	GameUtil.reset_tween(tween_one_col_wall)
		
	tween_one_col_wall = create_tween().set_parallel(true)
	tween_one_col_wall.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	for block: Bokoblock in bokobody.child_blocks:
		block.sprite_block.self_modulate = GameUtil.set_boko_color(is_block.boko_color)
		block.sprite_node_1.scale = Vector2.ONE / 4.0
		block.animator.anim_ghost()
		
		tween_one_col_wall.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)
	
	
func anim_blocks_exited_one_col_wall() -> void:
	var dur := 0.45
	
	GameUtil.reset_tween(tween_one_col_wall)
		
	tween_one_col_wall = create_tween().set_parallel(true)
	tween_one_col_wall.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	for block: Bokoblock in bokobody.child_blocks:
		block.sprite_block.self_modulate = GameUtil.set_boko_color(block.boko_color)
		block.sprite_node_1.scale = Vector2.ONE * 1.4
		
		tween_one_col_wall.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)


func anim_complete() -> void:
	var _tween: Tween
	
	if bokobody.particles_win:
		var p := bokobody.particles_win.instantiate() as CPUParticles2D
		add_child(p)
		p.global_rotation = 0.0
		p.emitting = true
		_tween = create_tween()
		_tween.tween_property(p,"self_modulate",Color(Color.WHITE,0.0),p.lifetime/2.0).set_delay(p.lifetime/2.0)
