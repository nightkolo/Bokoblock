extends Area2D
class_name Starpoint

@export var what_im_happy_with: GameUtil.BokoColor
@export_group("Object to Assign")
@export var sprite_star: Sprite2D
@export var particles_idle: CPUParticles2D
@export var particles_star: PackedScene = preload("res://world/world/particles_starpoint_happy.tscn")

var is_happy: bool = false:
	get:
		return is_happy
	set(value):
		if value:
			anim_happy()
		is_happy = value


func _ready() -> void:
	_setup_node()
	
	GameMgr.current_starpoints.append(self)


func _process(_delta: float) -> void:
	if particles_idle:
		particles_idle.global_rotation = 0.0

	
func _setup_node() -> void:
	check_satisfaction()
	anim_pulse()
	anim_star()
	
	if sprite_star:
		sprite_star.self_modulate = GameUtil.set_boko_color(what_im_happy_with)
	
	if particles_idle:
		particles_idle.self_modulate = GameUtil.set_boko_color(what_im_happy_with,2.0,0.5)


func check_satisfaction() -> bool:
	var value: bool
	var areas: Array[Area2D] = get_overlapping_areas()
	#var is_what_im_looking_for: bool = areas.size() == 1 && areas[0] is Bokoblock
	
	if areas.size() == 1 && areas[0] is Bokoblock:
		value = (areas[0] as Bokoblock).boko_color == what_im_happy_with
		
	is_happy = value
	
	return value


func anim_star() -> void:
	if sprite_star:
		var dur := 2.0
		
		var tween := create_tween().set_loops()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite_star,"rotation",deg_to_rad(-10.0),dur/2.0)
		tween.tween_property(sprite_star,"rotation",deg_to_rad(10.0),dur/2.0)


func anim_pulse() -> void:
	if sprite_star:
		var dur := 3.0
		
		var tween := create_tween().set_loops()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite_star,"self_modulate",GameUtil.set_boko_color(what_im_happy_with,1.25),dur/2.0)
		tween.tween_property(sprite_star,"self_modulate",GameUtil.set_boko_color(what_im_happy_with),dur/2.0)


func anim_happy() -> void:
	if particles_star:
		var p := particles_star.instantiate() as CPUParticles2D
		p.self_modulate = GameUtil.set_boko_color(what_im_happy_with,2.0,0.75)
		add_child(p)
		p.emitting = true
		await p.finished
		p.queue_free()
