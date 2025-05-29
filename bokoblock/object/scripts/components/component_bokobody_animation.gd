extends Node
class_name BokobodyAnimationComponent

signal somebody_entered_blackpoint_animation_finished()

@onready var bokobody: Bokobody = get_parent() as Bokobody

@export var particles_win: PackedScene = preload("res://world/world/particles_bokoblock_stage_complete.tscn")

var tween_one_col_wall: Tween
var tween_blackpoint: Tween


func _ready() -> void:
	if !(bokobody is Bokobody):
		push_error("%s is not a child of Bokobody." % str(self))
		return
	
	GameLogic.stage_won.connect(anim_complete)
	
	bokobody.somebody_entered_blackpoint.connect(anim_somebody_entered_blackpoint)
	bokobody.returned_from_blackpoint.connect(anim_returned_from_blackpoint)
	
	bokobody.child_block_entered_one_col_wall.connect(anim_blocks_entered_one_col_wall)
	bokobody.child_block_exited_one_col_wall.connect(anim_blocks_exited_one_col_wall)


func anim_somebody_entered_blackpoint() -> void:
	GameLogic.blackpoint_animating = true
	
	var dur := 0.4
	
	if tween_blackpoint:
		tween_blackpoint.kill()
		
	tween_blackpoint = create_tween().set_parallel(true)
	tween_blackpoint.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	for block: Bokoblock in bokobody.child_blocks:
		tween_blackpoint.tween_property(block.sprite_node_1,"rotation",PI,dur)
		tween_blackpoint.tween_property(block.sprite_node_1,"scale",Vector2.ZERO,dur)
	
	await get_tree().create_timer(dur).timeout
	
	somebody_entered_blackpoint_animation_finished.emit()
	GameLogic.blackpoint_animating = false


func anim_returned_from_blackpoint() -> void:
	var dur := 0.7
	
	if tween_blackpoint:
		tween_blackpoint.kill()
		
	tween_blackpoint = create_tween().set_parallel(true)
	tween_blackpoint.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	for block: Bokoblock in bokobody.child_blocks:
		block.sprite_node_1.rotation = 0.0

		tween_blackpoint.tween_property(block.sprite_node_1,"scale",Vector2.ONE,dur)
	
	
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
	if particles_win:
		var p := particles_win.instantiate() as CPUParticles2D
		bokobody.add_child(p)
		p.global_rotation = 0.0
		p.emitting = true
		var tween = create_tween()
		tween.tween_property(p,"self_modulate",Color(Color.WHITE,0.0),p.lifetime/2.0).set_delay(p.lifetime/2.0)
