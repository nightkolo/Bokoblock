extends Node2D
class_name CharacterChibiBoko

@export_group("Assets")
@export var texture_eyes_regular: Texture2D = preload("res://assets/characters/boko-chibi-eyes-upscale.png")
@export var texture_eyes_deadpan: Texture2D = preload("res://assets/characters/boko-chibi-eyes-deadpan.png")
@export var texture_4_star: Texture2D = preload("res://assets/characters/boko-chibi-star-01-upscale.png")
@export var texture_5_star: Texture2D = preload("res://assets/characters/boko-chibi-star-02.png")

@onready var anim: AnimationPlayer = $AnimEyes

@onready var node_body_1: Node2D = $Body1
@onready var node_body_2: Node2D = %Body2
@onready var node_head: Node2D = %Head

@onready var sprite_head: Sprite2D = %SpriteHead

@onready var node_eyes_1: Node2D = $Body1/Body2/Head/Eyes1
@onready var sprite_eyes_1: Sprite2D = %SpriteEyes
@onready var sprite_eyes_2: Sprite2D = %SpriteEyes2

@onready var node_top_hat: ChibiBokosTopHat = %TopHat
@onready var sprite_top_hat: Sprite2D = %SpriteTopHat
@onready var sprite_star: Sprite2D = %Star
@onready var star_dark: Sprite2D = %StarDark
@onready var sprite_star_ghost: Sprite2D = %StarGhost

var _process_star_spinning: bool


var tween_poke: Tween

func anim_poke() -> void:
	if tween_poke:
		tween_poke.kill()
	
	anim_wobble_top_hat(10.0, 1.5)
	
	tween_poke = create_tween().set_parallel(true)
	tween_poke.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	var dur_bounce := 1.0 * 0.3
	#var dur_delay := dur_bounce / 15.55
	var up := (Vector2.ONE / 1.3)
	#var down: Vector2
	var rot_to := signf(randf()-0.5) * (5.0 + (randf() * 4.0))
	var skew_to := signf(randf()-0.5) * (5.0 + (randf() * 4.0))

	#down = (Vector2.ONE * 1.3)
	
	sprite_head.scale = up
	sprite_head.rotation_degrees = rot_to
	sprite_head.skew = deg_to_rad(skew_to)
	
	#tween_poke.tween_property(sprite_head,"scale:x",1.0,dur_bounce)
	tween_poke.tween_property(sprite_head,"rotation_degrees",0.0,dur_bounce)
	tween_poke.tween_property(sprite_head,"skew",0.0,dur_bounce)
	tween_poke.tween_property(sprite_head,"scale",Vector2.ONE,dur_bounce)
	


func _process(delta: float) -> void:
	if _process_star_spinning:
		sprite_star.rotation += delta * (PI/2.0)
		star_dark.rotation += -1 * delta * (PI/2.0)



func pose_deadpan() -> void:
	node_top_hat.set_process(true)
	
	anim_bounce(true)
	
	anim_blink(true)
	anim_star_spinning(false)
	anim_breathing(true)
	anim_star_spinning(false)
	
	anim_wobble_top_hat(13.0, 1.2)
	
	anim.play(&"deadpan")
	
	#sprite_eyes_1.texture = texture_eyes_deadpan
	#sprite_eyes_1.flip_v = false


func pose_neutral() -> void:
	node_top_hat.set_process(true)
	
	anim_bounce(true)
	
	anim_blink(true)
	anim_star_spinning(false)
	anim_breathing(true)
	anim_star_spinning(false)
	
	anim_wobble_top_hat(13.0, 1.2)
	
	sprite_eyes_1.texture = texture_eyes_regular
	sprite_eyes_1.flip_v = false


var tween_happy: Tween

func pose_happy(spin_star: bool = true) -> void:
	var dur := 0.5
	
	node_top_hat.set_process(false)
	node_top_hat.scale = Vector2.ONE
	
	anim_bounce(false)
	
	anim_blink(false)
	anim_breathing(false)
	anim_star_ghost()
	anim_star_spinning(spin_star)
	anim_zeing(true)
	
	anim.play(&"happy")
	
	sprite_eyes_1.flip_v = true
	sprite_head.self_modulate = Color(Color.WHITE*1.75)
	
	if tween_happy:
		tween_happy.kill()
	
	tween_happy = create_tween()
	tween_happy.tween_property(sprite_head,"self_modulate",Color(Color.WHITE),dur)


func pose_asleep() -> void:
	anim_bounce(true)
	anim_breathing(true)
	anim_star_spinning(false)
	anim_zeing(true)
	
	anim.play(&"asleep")


func pose_woke() -> void:
	anim_breathing(true)
	anim_bounce(false)
	anim_wobble_top_hat()
	anim_star_spinning(false)
	anim_zeing(false)
	
	anim.play(&"woke_up")


var tween_breathe: Tween

func anim_breathing(breathe: bool = true) -> void:
	if breathe:
		var dur := 1.0
		var factor := 1.01
		_reset_tween(tween_breathe)
		
		tween_breathe = create_tween().set_loops()
		
		tween_breathe.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween_breathe.tween_property(node_body_1,"scale",Vector2(1.01*factor,0.87/factor),dur)
		tween_breathe.tween_property(node_body_1,"scale",Vector2.ONE,dur)
	else:
		_reset_tween(tween_breathe)
		node_body_1.scale = Vector2.ONE


var tween_speak: Tween

func start_speaking() -> void:
	
	var bounce_to := 1.25
	
	anim_blink(false)
	anim_breathing(false)
	
	_reset_tween(tween_speak)
	
	tween_speak = create_tween().set_loops()
	tween_speak.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE*bounce_to,0.1)
	tween_speak.tween_callback(_wobble_while_speaking)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE*(bounce_to/1.13),0.1)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE*(bounce_to/1.04),0.1)
	tween_speak.tween_callback(_wobble_while_speaking)
	tween_speak.tween_property(node_head,"scale",Vector2.ONE,0.1)


var tween_wobble: Tween
var _seed: float

func _wobble_while_speaking() -> void:
	var wobble_min := 2.5
	var wobble_rand_max := 3.5
	_seed = sign(randf()-0.5)
	var rot_to: float = (wobble_min + (randf() * wobble_rand_max)) * _seed
	
	node_head.rotation_degrees = rot_to
	
	_reset_tween(tween_wobble)
	tween_wobble = create_tween()
	tween_wobble.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_wobble.tween_property(node_head,"rotation_degrees",0.0,1.0)
	

func pause_speaking() -> void:
	if tween_speak:
		_reset_tween(tween_speak)
		
		tween_speak = create_tween()
		tween_speak.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween_speak.tween_property(node_head,"scale",Vector2.ONE,0.25)


func stop_speaking() -> void:
	if tween_speak:
		anim_wobble_top_hat(-_seed * 15.0, 3.4)
		
		_reset_tween(tween_speak)
		
		tween_speak = create_tween()
		tween_speak.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween_speak.tween_property(node_head,"scale",Vector2.ONE,1.0)


func anim_blink(blink: bool = true) -> void:
	anim_zeing(false)
	
	if blink:
		anim.play(&"blinking")
	else:
		anim.play(&"RESET")
		

func anim_star_spinning(spin: bool = true) -> void:
	if spin:
		star_dark.visible = true
		_process_star_spinning = true
	else:
		_process_star_spinning = false
		sprite_star.rotation = 0.0
		star_dark.rotation = 0.0
		star_dark.visible = false


func anim_zeing(Z_IT_JUST_Z_IIIIIIT: bool = true) -> void:
	(%Z as CPUParticles2D).emitting = Z_IT_JUST_Z_IIIIIIT


var tween_bounce: Tween
var tween_star_eye: Tween

func anim_excite(excite: bool = true): ## @experimental
	anim_star_spinning(excite)
	
	if excite:
		var dur := 0.25
		var dur_eyes := 0.8
		var stretch_to := Vector2(0.875,1.25)
		
		sprite_star.scale = Vector2.ZERO
		sprite_star.texture = texture_5_star
		sprite_eyes_1.visible = false
		sprite_eyes_2.visible = true
		node_eyes_1.scale = Vector2.ZERO
		
		anim_star_ghost()
		anim_blink(false)
		
		_reset_tween(tween_star_eye)
		_reset_tween(tween_bounce)
		
		tween_star_eye = create_tween()
		tween_bounce = create_tween().set_parallel(true)

		tween_star_eye.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_star_eye.tween_property(node_eyes_1,"scale", Vector2.ONE/2.0, dur_eyes)
		
		tween_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween_bounce.tween_property(node_body_2,"scale",stretch_to,dur)
		tween_bounce.tween_property(sprite_star,"scale",Vector2.ONE,dur*2.0)
		tween_bounce.tween_property(node_body_2,"scale",Vector2.ONE,dur/1.5).set_delay(dur*3.0)
		
		await get_tree().create_timer(dur_eyes).timeout
		
		anim_blink(true)
		sprite_eyes_1.visible = true
		sprite_eyes_2.visible = false
		node_eyes_1.scale = Vector2.ONE / 2.0
		
	else:
		anim_blink(true)
		
		sprite_star.texture = texture_4_star
		sprite_eyes_1.visible = true
		sprite_eyes_2.visible = false
		node_eyes_1.scale = Vector2.ONE / 2.0


var tween_star_ghost: Tween

func anim_star_ghost() -> void:
	var dur := 0.8
	
	sprite_star_ghost.scale = Vector2.ZERO
	sprite_star_ghost.self_modulate = Color(Color.WHITE,1.0)
	
	_reset_tween(tween_star_ghost)
	tween_star_ghost = create_tween().set_parallel()
	tween_star_ghost.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween_star_ghost.tween_property(sprite_star_ghost,"scale",Vector2.ONE*2.0,dur).set_trans(Tween.TRANS_EXPO)
	tween_star_ghost.tween_property(sprite_star_ghost,"self_modulate",Color(Color.WHITE,0.0),dur)


var tween_wobble_top_hat: Tween

func anim_wobble_top_hat(amplitude: float = 10.0, duration: float = 1.0) -> void:
	var amp := amplitude
	var dur := duration
	
	_reset_tween(tween_wobble_top_hat)
	tween_wobble_top_hat = create_tween()
	tween_wobble_top_hat.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp,dur/18.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp,dur/18.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp/2.0,dur/13.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp/2.0,dur/13.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp/4.0,dur/13.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp/4.0,dur/13.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",amp/8.0,dur/13.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",-amp/8.0,dur/13.0)
	tween_wobble_top_hat.tween_property(node_top_hat,"rotation_degrees",0.0,dur/13.0)


var tween_bounce_2: Tween

func anim_bounce(back: bool = false) -> void:
	var bounce_to: Vector2
	
	if back:
		bounce_to = Vector2(1.2,0.8)
		var ease_in := 0.125
		
		_reset_tween(tween_bounce_2)
		tween_bounce_2 = create_tween().set_parallel(true)
		tween_bounce_2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween_bounce_2.tween_property(node_body_2,"scale",bounce_to,ease_in)
		tween_bounce_2.tween_property(node_body_2,"scale",Vector2.ONE,0.5).set_delay(ease_in)
	else:
		bounce_to = Vector2(0.75,1.25)
		var top_hat_go_to: float = abs(bounce_to.y * 10.0) * -1
		var top_hat_pos: float = sprite_top_hat.position.y
		
		_reset_tween(tween_bounce)

		node_body_2.scale = bounce_to
		sprite_top_hat.position.y += top_hat_go_to
		tween_bounce = create_tween().set_parallel(true)
		tween_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween_bounce.tween_property(sprite_top_hat,"position:y",top_hat_pos,0.5)
		tween_bounce.tween_property(node_body_2,"scale",Vector2.ONE,0.5)


func _reset_tween(t: Tween) -> void:
	if t:
		t.kill()
