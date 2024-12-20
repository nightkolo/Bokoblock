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

var _tween_breathe: Tween
var _tween_bounce: Tween



func _ready() -> void:
	pass
	#await get_tree().create_timer(0.5).timeout
	#anim_bounce(true)
	#anim_breathe()

func anim_bounce(_then_breathe: bool = false) -> void: # LOL the param name.
	var dur := 1.0
	
	if _tween_bounce:
		_tween_bounce.kill()
	
	node_body_1.scale = Vector2.ONE
	
	_tween_bounce = create_tween()
	_tween_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	_tween_bounce.tween_property(node_body_1,"scale",Vector2(0.75,1.25),dur/12.0)
	_tween_bounce.tween_property(node_body_1,"scale",Vector2.ONE,dur).set_trans(Tween.TRANS_ELASTIC)
		
		
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
