extends CollisionShape2D
class_name OneColorWall

@onready var node_sprites: Node2D = $Sprite
@onready var sprite_2d: Sprite2D = $Sprite/Sprite2D
@onready var cross: Sprite2D = $Sprite/Cross
@onready var cross_2: Sprite2D = $Sprite/Cross2


func _ready() -> void:
	GameMgr.colorblind_mode_setting_set.connect(func(_is_on: bool):
		set_texture()
		)
	GameMgr.game_pause_toggled.connect(func(p: bool):
		if !p:
			set_texture()
		)
	
	set_texture()
	
	anim_idle()
	await get_tree().create_timer(1.0).timeout
	anim_idle_2()


func set_texture() -> void:
	if GameMgr.get_colorblind_mode_setting():
		sprite_2d.texture = preload("res://assets/objects/one-color-wall-colorblind.png")
	else:
		sprite_2d.texture = preload("res://assets/objects/one-color-wall.png")
		


func anim_idle() -> void:
	var dur := 2.0
	
	var tween = create_tween().set_loops()
	#var tween_rot = create_tween().set_loops()

	var tween_fade = create_tween().set_loops()
	
	
	tween.tween_property(cross, "scale", Vector2.ZERO,0.0)
	tween.tween_property(cross, "scale", Vector2.ONE * 0.5,dur)
	
	
	#tween_rot.tween_property(cross, "rotation", PI / 4.0 ,0.0)
	#tween_rot.tween_property(cross, "rotation", 0.0,dur)
	
	tween_fade.tween_property(cross, "self_modulate", Color(Color.WHITE, 0.25), 0.0)
	tween_fade.tween_property(cross, "self_modulate", Color(Color.WHITE, 0.0), dur / 2.0).set_delay(dur / 2.0)

func anim_idle_2() -> void:
	var dur := 2.0
	
	var tween = create_tween().set_loops()
	#var tween_rot = create_tween().set_loops()

	var tween_fade = create_tween().set_loops()
	
	
	tween.tween_property(cross_2, "scale", Vector2.ZERO,0.0)
	tween.tween_property(cross_2, "scale", Vector2.ONE * 0.5,dur)
	
	
	#tween_rot.tween_property(cross_2, "rotation", PI / 4.0 ,0.0)
	#tween_rot.tween_property(cross_2, "rotation", 0.0,dur)
	
	tween_fade.tween_property(cross_2, "self_modulate", Color(Color.WHITE, 0.25), 0.0)
	tween_fade.tween_property(cross_2, "self_modulate", Color(Color.WHITE, 0.0), dur / 2.0).set_delay(dur / 2.0)
