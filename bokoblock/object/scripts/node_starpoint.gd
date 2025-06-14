extends Area2D
class_name Starpoint

@export var what_im_happy_with: GameUtil.BokoColor
@export var colorblind_label: GameUtil.ColorblindLabel
@export_group("Object to Assign")
@export var sprite_star: Sprite2D
@export var particles_idle: CPUParticles2D
@export var particles_star: PackedScene = preload("res://world/world/particles_starpoint_happy.tscn")
@export_group("Assets")
@export var asset_starpoint: Texture2D = preload("res://assets/objects/starpoint.png")
@export_subgroup("Assets colorblind mode")
@export var asset_starpoint_cb_1: Texture2D = preload("res://assets/objects/starpoint-colorblind-01.png")
@export var asset_starpoint_cb_2: Texture2D = preload("res://assets/objects/starpoint-colorblind-02.png")
@export var asset_starpoint_cb_3: Texture2D = preload("res://assets/objects/starpoint-colorblind-03.png")
@export var asset_starpoint_cb_4: Texture2D = preload("res://assets/objects/starpoint-colorblind-04.png")
@export_group("SFX")
@export var audio_wrong: AudioStreamPlayer2D
@export var audio_entered: AudioStreamPlayer2D
@export var audio_exited: AudioStreamPlayer2D

var is_happy: bool = false:
	get:
		return is_happy
	set(value):
		if value:
			anim_happy()
		
		if value != is_happy && !GameLogic.has_won:
			if value:
				audio_entered.play()
			else:
				audio_exited.play()
				
		is_happy = value
var is_landed_on: bool = false:
	set(value):
		is_landed_on = value
		
		if value && !is_happy:
			audio_wrong.play()
			


func _ready() -> void:
	_setup_node()
	
	GameMgr.colorblind_mode_setting_set.connect(func(_is_on: bool):
		_set_star_texture()
		)
	GameMgr.game_pause_toggled.connect(func(p: bool):
		if !p:
			_set_star_texture()
		)
	GameLogic.current_starpoints.append(self)


func _process(_delta: float) -> void:
	if particles_idle:
		particles_idle.global_rotation = 0.0

	
func _setup_node() -> void:
	check_satisfaction()
	anim_idle()
	
	if sprite_star:
		sprite_star.rotation_degrees = deg_to_rad(10.0)
		_set_star_texture()
	
	if particles_idle:
		particles_idle.self_modulate = GameUtil.set_boko_color(what_im_happy_with,2.0,0.5)


func _set_star_texture() -> void:
	var l_texture: Texture
	
	if GameMgr.get_colorblind_mode_setting():
		if tween_pulse:
			tween_pulse.kill()
		
		match colorblind_label:
			
			GameUtil.ColorblindLabel.Label_1:
				l_texture = asset_starpoint_cb_1
				
			GameUtil.ColorblindLabel.Label_2:
				l_texture = asset_starpoint_cb_2
				
			GameUtil.ColorblindLabel.Label_3:
				l_texture = asset_starpoint_cb_3
				
			GameUtil.ColorblindLabel.Label_4:
				l_texture = asset_starpoint_cb_4
				
		sprite_star.self_modulate = Color(Color.WHITE, 1.0)
	
	else:
		anim_pulse()
		
		l_texture = asset_starpoint
		sprite_star.self_modulate = GameUtil.set_boko_color(what_im_happy_with)
	
	sprite_star.texture = l_texture


func setup_node() -> void:
	_setup_node()


func check_satisfaction(modify_happiness: bool = true) -> bool:
	var value: bool
	var areas: Array[Area2D] = get_overlapping_areas()
	
	is_landed_on = areas.size() == 1 && areas[0] is Bokoblock

	if is_landed_on:
		value = (areas[0] as Bokoblock).boko_color == what_im_happy_with
	
	if modify_happiness:
		is_happy = value
	
	return value


func anim_idle() -> void:
	if sprite_star:
		var dur := 1.0
		
		var tween := create_tween().set_loops()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite_star,"rotation",deg_to_rad(-10.0),dur)
		tween.tween_property(sprite_star,"rotation",deg_to_rad(10.0),dur)


var tween_pulse: Tween


func anim_pulse() -> void:
	if sprite_star:
		var dur := 3.0
		
		if tween_pulse:
			tween_pulse.kill()
		
		tween_pulse = create_tween().set_loops()
		tween_pulse.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween_pulse.tween_property(sprite_star,"self_modulate",GameUtil.set_boko_color(what_im_happy_with,1.25),dur/2.0)
		tween_pulse.tween_property(sprite_star,"self_modulate",GameUtil.set_boko_color(what_im_happy_with),dur/2.0)


func anim_happy() -> void:
	if particles_star:
		var p := particles_star.instantiate() as CPUParticles2D
		p.self_modulate = GameUtil.set_boko_color(what_im_happy_with,2.0,0.75)
		add_child(p)
		p.emitting = true
		await p.finished
		p.queue_free()
