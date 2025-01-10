## Under construction
extends Node2D
class_name ChibiBoko

@export var bounce_dur: float = 0.5
@export var speaking_speed: float = 1.0 ## Somehow adjusts the speed, but my math is admittedly not staight forward... wip
@export var texture_eyes_open: Texture2D = preload("res://assets/characters/chibi-boko/boko-chibi-eyes.png")

@onready var anim: AnimationPlayer = $AnimEyes
@onready var node_body_1: Node2D = $Body1
@onready var node_body_2: Node2D = %Body2
@onready var node_head: Node2D = %Head
@onready var node_eyes: Node2D = %Eyes
@onready var node_top_hat: ChibiBokosTopHat = %TopHat
@onready var sprite_head: Sprite2D = %SpriteHead
@onready var sprite_eyes: Sprite2D = %SpriteEyes
@onready var sprite_top_hat: Sprite2D = %SpriteTopHat
@onready var sprite_star: Sprite2D = %Star
@onready var star_dark: Sprite2D = %StarDark
@onready var sprite_star_ghost: Sprite2D = %StarGhost

var _seed: float
var _tween_breathe: Tween
var tween_happy: Tween
var tween_bounce: Tween
var tween_bounce_2: Tween
var tween_speak: Tween
var tween_wobble: Tween
var _tween_star_rot: Tween
var _tween_star_bounce: Tween
var _tween_star_spinning: Tween
var _tween_star_ghost: Tween
var _tween_wobble_top_hat: Tween
var _process_star_spinning: bool


func _process(delta: float) -> void:
	if _process_star_spinning:
		sprite_star.rotation += delta * PI
		star_dark.rotation += -1 * delta * PI


func eyes_happy() -> void:
	anim.play(&"happy")


func start_breathing() -> void:
	reset_tween(_tween_breathe)
	
	_tween_breathe = create_tween().set_loops()
	
	_tween_breathe.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween_breathe.tween_property(node_body_1,"scale",Vector2(1.05,0.9),1.0)
	_tween_breathe.tween_property(node_body_1,"scale",Vector2.ONE,1.0)


## Don't worry, chibi boko has no lungs, the breathing is just an illusion.
func stop_breathing() -> void:
	reset_tween(_tween_breathe)
	node_body_1.scale = Vector2.ONE


func start_speaking() -> void:
	var bounce_to := 1.225
	
	stop_blinking()
	stop_breathing()
	
	reset_tween(tween_speak)
	
	tween_speak = create_tween().set_loops()
	tween_speak.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE*bounce_to,speaking_speed)
	tween_speak.tween_callback(wobble_while_speaking)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE*(bounce_to/1.13),speaking_speed)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE*(bounce_to/1.04),speaking_speed)
	tween_speak.tween_callback(wobble_while_speaking)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE,speaking_speed)
	
	
func wobble_while_speaking() -> void:
	var wobble_min := 6.0 
	var wobble_rand_max := 5.0
	_seed = sign(randf()-0.5)
	var rot_to: float = (wobble_min + (randf() * wobble_rand_max)) * _seed
	
	node_head.rotation_degrees = rot_to
	
	reset_tween(tween_wobble)
	tween_wobble = create_tween()
	tween_wobble.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_wobble.tween_property(node_head,"rotation_degrees",0.0,speaking_speed*20.0)


## If you wanna scream at chibi boko instead...
func shut_up() -> void:
	stop_speaking()
	

func stop_speaking() -> void:
	# TODO: Chibi boko does not blink after stop_speaking
	if tween_speak:
		anim_star_bounce(0.6)
		anim_star_spin(45.0)
		anim_wobble_top_hat(-_seed * 10.0, 2.0)
		start_breathing()
		
		reset_tween(tween_speak)
		
		tween_speak = create_tween()
		tween_speak.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween_speak.tween_property(node_head,"scale",Vector2.ONE,speaking_speed)


func start_blinking() -> void:
	anim.play(&"blinking")
	

func stop_blinking() -> void:
	anim.play(&"RESET")
	

func start_star_spinning() -> void:
	reset_tween(_tween_star_spinning)
	
	star_dark.visible = true
	_process_star_spinning = true


func stop_star_spinning() -> void:
	_process_star_spinning = false
	sprite_star.rotation = 0.0
	star_dark.rotation = 0.0
	star_dark.visible = false
	anim_star_bounce(0.3)


func be_neutral() -> void:
	node_top_hat.set_process(true)
	
	anim_bounce_back()
	start_blinking()
	start_breathing()
	stop_star_spinning()
	anim_wobble_top_hat(11.0)
	
	sprite_eyes.texture = texture_eyes_open
	sprite_eyes.flip_v = false


func be_happy() -> void:
	var dur := 0.5
	
	node_top_hat.set_process(false)
	node_top_hat.scale = Vector2.ONE
	
	anim_bounce()
	eyes_happy()
	anim_star_ghost()
	anim_star_bounce(0.25)
	start_star_spinning()
	stop_breathing()
	
	sprite_eyes.flip_v = true
	sprite_head.self_modulate = Color(Color.WHITE*2.5)
	
	tween_happy = create_tween()
	tween_happy.tween_property(sprite_head,"self_modulate",Color(Color.WHITE),dur)


func anim_star_ghost() -> void:
	var dur := 0.8
	
	sprite_star_ghost.scale = Vector2.ZERO
	sprite_star_ghost.self_modulate = Color(Color.WHITE,1.0)
	
	reset_tween(_tween_star_ghost)
	_tween_star_ghost = create_tween().set_parallel()
	_tween_star_ghost.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	_tween_star_ghost.tween_property(sprite_star_ghost,"scale",Vector2.ONE*2.0,dur).set_trans(Tween.TRANS_EXPO)
	_tween_star_ghost.tween_property(sprite_star_ghost,"self_modulate",Color(Color.WHITE,0.0),dur)


func anim_wobble_top_hat(amplitude: float = 10.0, duration: float = 1.0) -> void:
	var amp := amplitude
	var dur := duration
	
	reset_tween(_tween_wobble_top_hat)
	_tween_wobble_top_hat = create_tween()
	_tween_wobble_top_hat.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp,dur/18.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp,dur/18.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp/2.0,dur/13.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp/2.0,dur/13.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp/4.0,dur/13.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp/4.0,dur/13.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp/8.0,dur/13.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp/8.0,dur/13.0)
	_tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",0.0,dur/13.0)


func anim_star_spin(spin_to: float = randf_range(25.0,90.0)) -> void:
	var dur := 2.5
	var rand_sign: float = sign(randf()-0.5)
	
	reset_tween(_tween_star_rot)
	
	sprite_star.rotation = deg_to_rad(spin_to) * rand_sign
	
	_tween_star_rot = create_tween()
	_tween_star_rot.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	_tween_star_rot.tween_property(sprite_star,"rotation",0.0,dur)


func anim_star_bounce(bounce_down_to: float = 0.75) -> void:
	var dur := 1.25
	var delay := dur / 13.33
	
	reset_tween(_tween_star_bounce)
	
	sprite_star.scale = Vector2.ONE*bounce_down_to
	
	_tween_star_bounce = create_tween().set_parallel(true)
	_tween_star_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	_tween_star_bounce.tween_property(sprite_star,"scale:x",1.0,dur)
	_tween_star_bounce.tween_property(sprite_star,"scale:y",1.0,dur).set_delay(delay)


func anim_bounce() -> void:
	var bounce_to := Vector2(0.75,1.25)
	var top_hat_go_to: float = abs(bounce_to.y * 10.0) * -1
	var top_hat_pos: float = sprite_top_hat.position.y
	
	reset_tween(tween_bounce)

	node_body_2.scale = bounce_to
	sprite_top_hat.position.y += top_hat_go_to
	tween_bounce = create_tween().set_parallel(true)
	tween_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_bounce.tween_property(sprite_top_hat,"position:y",top_hat_pos,bounce_dur)
	tween_bounce.tween_property(node_body_2,"scale",Vector2.ONE,bounce_dur)


func anim_bounce_back():
	var bounce_to := Vector2(1.2,0.8)
	var ease_in := bounce_dur/4.0
	
	reset_tween(tween_bounce_2)
	tween_bounce_2 = create_tween().set_parallel(true)
	tween_bounce_2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_bounce_2.tween_property(node_body_2,"scale",bounce_to,ease_in)
	tween_bounce_2.tween_property(node_body_2,"scale",Vector2.ONE,bounce_dur).set_delay(ease_in)


func reset_tween(t: Tween) -> void:
	if t:
		t.kill()
