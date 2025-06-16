extends Node2D

@export var monolog_script: Monolog

@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var node_float: Node2D = $Float
@onready var sprite_base: Sprite2D = $Float/Base
@onready var sprite_arrow: Sprite2D = $Float/Arrow


func _ready() -> void:
	anim_idle()
	anim_click_me()
	
	if monolog_script:
		monolog_script.letter_showing_finished.connect(func():
			pass
			)
		monolog_script.monolog_line_entered.connect(func(_a: int):
			anim_clicked()
			)
			
			

var t_clicked: Tween

func anim_clicked() -> void:
	var dur := 1.5

	anim.play(&"clicked", -1, 1.25)
	
	sprite_base.scale = Vector2(1.4, 0.6)
	#sprite_base.skew = deg_to_rad(20.0 + (25.0 * (randf() - 0.5)))
	sprite_arrow.scale = Vector2.ONE * 2.0 * randi_range(0, 1)
	
	if t_clicked:
		t_clicked.kill()
	
	t_clicked = create_tween().set_parallel(true)
	t_clicked.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	t_clicked.tween_property(sprite_base, "scale", Vector2.ONE, dur)
	t_clicked.tween_property(sprite_base, "skew", 0.0, dur)
	
	t_clicked.tween_property(sprite_arrow, "scale", Vector2.ONE, dur)
	
	#await t_clicked.finished
	await t_clicked.finished
	
	anim_click_me()


func anim_click_me() -> void:
	var squeeze := Vector2(1.15, 0.85)
	var dur := 1.5
	var dur_loop := 0.2
	
	if t_clicked:
		t_clicked.kill()
	
	t_clicked = create_tween().set_loops()
	t_clicked.set_ease(Tween.EASE_OUT)
	t_clicked.tween_property(sprite_base, "scale", squeeze, dur/10.0).set_delay(dur_loop)
	t_clicked.tween_property(sprite_base, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	


func anim_idle() -> void:
	var tween := create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(node_float, "position:y", -5.0, 1.0)
	tween.tween_property(node_float, "position:y", 5.0, 1.0)
	
	#var tween_b := create_tween().set_loops()
	#tween_b.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#
	#tween_b.tween_property(sprite_arrow, "position:y", -2.0, 0.6)
	#tween_b.tween_property(sprite_arrow, "position:y", 2.0, 0.6)
	
	
	
func anim_bounce() -> void:
	pass
