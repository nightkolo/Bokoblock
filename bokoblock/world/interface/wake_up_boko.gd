extends Node2D
class_name WakeUpBoko

signal have_awoken()
signal closer_wake(waking: float)

@export var top_hat_man: CharacterChibiBoko

@onready var wake_up_boko_btn: Button = $WakeUpBokoButton

@onready var node_sign_1: Node2D = %Sign1
@onready var node_sign_2: Node2D = %Sign2
@onready var sprite_sign_arrow: Sprite2D = %Arrow
@onready var nine_patch_rect: NinePatchRect = $Sign1/Sign2/NinePatchRect

@onready var boko_click: Node = $BokoClick
@onready var boko_wake: Node = $BokoWake
@onready var label: Label = $Label

var _click_sounds: Array[Node]
var _wake_sounds: Array[Node]

var times_to_wake: int = 0 
var times_clicked: int = 0
var have_woken: bool = false

var tween_swing: Tween


func _ready() -> void:
	times_to_wake = randi_range(6, 9)
	#times_to_wake = 1
	#print(times_to_wake)
	
	node_sign_1.visible = false
	label.self_modulate = Color(Color.WHITE, 0.0)
	
	anim_arrow()
	
	_wake_sounds = boko_wake.get_children()
	_click_sounds = boko_click.get_children()
	
	have_awoken.connect(func():
		MedalMgr.unlocked("Wake Up Poko")
		MedalMgr.unlock_a_medal("wake_up_call")
		
		var aud := _wake_sounds.pick_random() as AudioStreamPlayer
		aud.play()
		)
	
	wake_up_boko_btn.pressed.connect(func():
		have_woken = times_clicked == times_to_wake
		
		var aud := _click_sounds.pick_random() as AudioStreamPlayer
		aud.play()
		
		if have_woken:
			have_awoken.emit()
		else:
			times_clicked += 1
			
			top_hat_man.anim_poke()
			anim_click()
			
			closer_wake.emit( float(times_clicked) / float(times_to_wake) )
		)


func click_notice():
	await get_tree().create_timer(6.0).timeout

	var tween := create_tween()
	tween.tween_property(label, "self_modulate", Color(Color.WHITE, 0.5), 1.0)


var tween_click: Tween


func anim_click():
	nine_patch_rect.scale = Vector2.ONE * 0.75
	
	if tween_click:
		tween_click.kill()
		
	tween_click = create_tween()
	tween_click.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween_click.tween_property(nine_patch_rect, "scale", Vector2.ONE, 0.8)
	


func anim_wake_up_boko():
	var dur := 1.0
	
	node_sign_2.modulate = Color(Color.WHITE, 0.0)
	node_sign_2.scale = Vector2.ZERO
	node_sign_2.rotation = PI / 2.0
	
	node_sign_1.visible = true
	
	click_notice()
	anim_swing(dur)
	
	var tween := create_tween().set_parallel(true)
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(node_sign_2,"modulate", Color(Color.WHITE, 1.0), 1.0)
	tween.tween_property(node_sign_2,"scale", Vector2.ONE, 1.0)
	
	tween.tween_property(node_sign_2,"rotation", 0.0, 1.0)


func anim_swing(dur: float):
	var mag := PI / 48.0
	var loop_dur := 2.0
	
	var tween := create_tween()
	
	tween.tween_property(node_sign_1,"rotation", -mag, dur)
	
	await tween.finished
	
	if have_woken:
		return
	
	tween_swing = create_tween().set_loops()
	
	tween_swing.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_swing.tween_property(node_sign_1,"rotation", mag, loop_dur)
	tween_swing.tween_property(node_sign_1,"rotation", -mag, loop_dur)
	

func anim_arrow():
	var tween := create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_sign_arrow, "position:y", 10.0, 0.7).as_relative()
	tween.tween_property(sprite_sign_arrow, "position:y", -10.0, 0.7).as_relative()
	

func anim_boko_woke_up():
	var dur := 0.5
	
	label.visible = false
	
	if tween_swing:
		tween_swing.kill()
	
	var tween_a := create_tween()
	var tween_b := create_tween().set_parallel(true)
	
	tween_a.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	#tween_b.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
	# It's hard to simulate projectile motion...
	
	tween_a.tween_property(node_sign_1, "position:y", -100.0, dur).as_relative()
	
	tween_a.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
	tween_a.tween_property(node_sign_1, "position:y", 1000.0, dur*1.25).as_relative()
	
	tween_b.tween_property(node_sign_1, "position:x", 200.0, dur*3.0).as_relative()
	
	tween_b.tween_property(node_sign_1, "modulate", Color(Color.WHITE, 0.0), dur*1.3)
	
