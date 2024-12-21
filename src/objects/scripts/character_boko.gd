## (Very) under construction.
extends Node2D
class_name CharacterBoko

@onready var node_body_1: Node2D = %Body1
@onready var node_body_2: Node2D = %Body2
@onready var sprite_packed: Sprite2D = %Packed
@onready var sprite_also_body: Sprite2D = %AlsoBody
@onready var node_head: Node2D = %Head
@onready var sprite_sprite_head: Sprite2D = %SpriteHead
@onready var node_eyes: Node2D = %Eyes
@onready var sprite_sprite_eyes: Sprite2D = %SpriteEyes
@onready var node_top_hat: Node2D = %TopHat
@onready var sprite_sprite_top_hat: Sprite2D = %SpriteTopHat
@onready var sprite_star: Sprite2D = %Star
@onready var sprite_right_hand: Sprite2D = %RightHand
@onready var sprite_left_hand: Sprite2D = %LeftHand

@onready var anim: AnimationPlayer = $AnimationPlayer
var _tween_breathe: Tween
var _tween_bounce: Tween
var _tween_star_bounce: Tween

var _tween_star_rot: Tween



func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	#anim_bounce(true)
	anim_breathe()


func pose_thinking() -> void:
	anim.play("pose_thinking")
	if _tween_breathe:
		_tween_breathe.kill()
		
	#anim_star_bounce()
	#anim_star_spin()


func pose_normal() -> void:
	anim.play("RESET")
	anim_breathe()
	#anim_star_bounce()
	#anim_star_spin()
	
	
func pose_no_worry() -> void:
	anim.play("pose_no_worries")
	anim_breathe()
	#anim_star_bounce()
	#anim_star_spin()
	
	
func pose_excited() -> void:
	anim.play("pose_excited")
	anim_breathe()
	#anim_star_bounce()
	#anim_star_spin()


func pose_wink() -> void:
	anim.play("pose_wink")
	anim_breathe()
	#anim_star_bounce()
	#anim_star_spin()


func anim_star_spin(spin_to: float = randf_range(25.0,90.0)) -> void:
	var dur := 2.5
	var rand_sign: float = sign(randf()-0.5)
	
	if _tween_star_rot:
		_tween_star_rot.kill()
	
	sprite_star.rotation = deg_to_rad(spin_to) * rand_sign
	
	_tween_star_rot = create_tween().set_parallel(true)
	_tween_star_rot.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	_tween_star_rot.tween_property(sprite_star,"rotation",deg_to_rad(10.0),dur)


func anim_star_bounce(bounce_down_to: float = 0.75) -> void:
	var dur := 1.0
	var delay := dur / 13.33
	
	if _tween_star_bounce:
		_tween_star_bounce.kill()
	
	sprite_star.scale = Vector2.ONE*bounce_down_to
	
	_tween_star_bounce = create_tween().set_parallel(true)
	_tween_star_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	_tween_star_bounce.tween_property(sprite_star,"scale:x",1.0,dur)
	_tween_star_bounce.tween_property(sprite_star,"scale:y",1.0,dur).set_delay(delay)


func anim_bounce(_then_breathe: bool = false) -> void: # LOL the param name.
	var dur := 0.5
	
	if _tween_bounce:
		_tween_bounce.kill()
	
	node_body_1.scale = Vector2.ONE
	
	_tween_bounce = create_tween()
	_tween_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	_tween_bounce.tween_property(node_body_1,"scale",Vector2(0.75,1.25),dur/12.0)
	_tween_bounce.tween_property(node_body_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_BACK)
		
		
	#await get_tree().create_timer(dur).timeout
	#await _tween_bounce.finished
	#
	#if then_breathe:
		#anim_breathe()
	

func anim_breathe() -> void:
	if _tween_breathe:
		_tween_breathe.kill()
	
	_tween_breathe = create_tween().set_loops()
	
	_tween_breathe.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_breathe.tween_property(node_body_2,"scale",Vector2(1.05,0.95),1.0)
	_tween_breathe.tween_property(node_body_2,"scale",Vector2.ONE,1.0)
