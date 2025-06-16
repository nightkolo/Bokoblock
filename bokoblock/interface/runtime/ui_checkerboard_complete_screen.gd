extends Control
class_name CBCompleteScreen

@export var asset_star: Texture2D = preload("res://assets/interface/rabbitstar-yellow.png")
@export var asset_checkmark: Texture2D = preload("res://assets/interface/checkerboard-complete-checkmark-checkerboard-complete.png")

@onready var bg: ColorRect = $BG
@onready var node_texture_1: Node2D = %TextureNode1
@onready var node_texture_2: Node2D = %TextureNode2
@onready var texture: Sprite2D = %Texture
@onready var panel: NinePatchRect = %Panel

@onready var cb_complete_info: RichTextLabel = %CBCompleteInfo
@onready var next_btn: Button = %NextButton

var tween_texture_idle: Tween
var tween_texture_hover: Tween
var tween_texture_pulse: Tween

var _gameplay_ui: GameplayUI
var _final_texture_scale: Vector2 = Vector2.ONE * 0.45

const _INFO_BEGIN = "Checkerboard "
const _INFO_END = " Complete!"


func _ready() -> void:
	update_text()
	
	texture.scale = _final_texture_scale
	
	if get_parent() is GameplayUI:
		_gameplay_ui = get_parent() as GameplayUI
		
	else:
		push_warning(str(self) + " must be run under GameplayUI.")
		next_btn.grab_focus()
		get_tree().paused = true
		visible = true
	
	visibility_changed.connect(func():
		if visible:
			next_btn.grab_focus()
			update_text()
		)
		
	next_btn.pressed.connect(func():
		stop_anim_idle()
		
		GameMgr.goto_next_checkerboard()
		)
		
	(%TextureButton as Button).pressed.connect(anim_click)


#func _process(_delta: float) -> void:
	#(%Particles3 as CPUParticles2D).position = get_local_mouse_position()


func open() -> void:
	GameMgr.menu_entered.emit(GameMgr.Menus.CHECKERBOARD_COMPLETE)
	Audio.set_music( Audio.original_music_db - 15.0 )
	visible = true
	
	update_text()
	anim_open()


func update_text() -> void:
	if GameMgr.get_reduce_motion_setting():
		cb_complete_info.text = GameplayUI.BBCODE_TXT_NO_MOTION + _INFO_BEGIN + str(GameMgr.checkerboard_id) + _INFO_END
	else:
		cb_complete_info.text = GameplayUI.BBCODE_TXT + _INFO_BEGIN + str(GameMgr.checkerboard_id) + _INFO_END
		

func anim_shine():
	var tween_a = create_tween().set_loops()
	var tween_b = create_tween().set_loops()
	
	(%Shine1 as Sprite2D).visible = true
	(%Shine2 as Sprite2D).visible = true
	
	tween_a.tween_property((%Shine1 as Sprite2D), "rotation", PI / 4.0, 1.0).as_relative()
	tween_b.tween_property((%Shine2 as Sprite2D), "rotation", -PI / 4.0, 1.0).as_relative()
	

func stop_anim_idle() -> void:
	if tween_texture_idle:
		tween_texture_idle.kill()
	
	if tween_texture_hover:
		tween_texture_hover.kill()
	
	if tween_texture_pulse:
		tween_texture_pulse.kill()
		
var tween_click: Tween


func anim_click() -> void:
	var mag := 0.15
	var dur := 1.5
	
	if tween_click:
		tween_click.kill()
	
	node_texture_1.scale = Vector2(1.0+mag, 1.0-mag)
	node_texture_1.skew = deg_to_rad(10.0 + (7.5 * (randf() - 0.5)))
	
	tween_click = create_tween().set_parallel(true)
	tween_click.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween_click.tween_property(node_texture_1, "scale", Vector2.ONE, dur)
	tween_click.tween_property(node_texture_1, "skew", 0.0, dur)


func anim_open() -> void:
	anim_texture_spinning()
	
	var dur := 2.25
	var delay := dur / 12.0
	
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	panel.pivot_offset = Vector2(panel.size.x / 2.0, panel.size.y)
	panel.scale = Vector2.ZERO
	
	tween.tween_property(panel, "scale:y", 1.0, dur)
	tween.tween_property(panel, "scale:x", 1.0, dur).set_delay(delay)
	
	# await tween.finished # doesn't work since it's set to parallel
	await get_tree().create_timer(dur).timeout
	tween.kill()
	
	
func anim_texture_spinning() -> void:
	var dur := 1.2
	var bg_mag := 1.0
	
	# Spin
	node_texture_1.rotation = 3.5 * PI
	texture.position.x -= 600.0
	
	# Scale and texture
	texture.texture = asset_star
	texture.scale = Vector2.ONE * 2.0
	
	var tween = create_tween().set_parallel(true)
	var tween_bg = create_tween()
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(texture, "position", Vector2.ZERO, dur)
	tween.tween_property(texture, "scale", _final_texture_scale, dur)
	
	tween.tween_property(node_texture_2, "scale", Vector2.ZERO, dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(node_texture_1, "rotation", 0.0, dur)
	
	tween_bg.tween_property(bg, "color", Color(Color.BLACK, bg_mag), dur)
	
	await tween_bg.finished
	tween_bg.kill()
	
	_anim_texture_landed()
	
	# await tween.finished # doesn't work since it's set to parallel
	await get_tree().create_timer(dur).timeout
	tween.kill()
	

func _anim_texture_landed():
	var dur_pop := 1.6
	var dur_bg := 0.5
	var delay_bg := 0.1
	
	texture.texture = asset_checkmark
	bg.color = Color(Color.WHITE, 1.0)
	node_texture_2.scale = -Vector2.ONE * 0.25
	
	Audio.checkerboard_complete.play()
	(%Particles as CPUParticles2D).emitting = true
	(%Particles2 as CPUParticles2D).emitting = true
	(%Particles3 as CPUParticles2D).emitting = true
	
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_property(node_texture_2, "scale", Vector2.ONE, dur_pop).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(bg, "color", Color(Color.WHITE, 0.2), dur_bg).set_delay(delay_bg)
	
	anim_texture_idle()
	anim_shine()
	
	# await tween.finished # doesn't work since it's set to parallel
	await get_tree().create_timer(dur_pop).timeout
	tween.kill()


func anim_texture_idle() -> void:
	var dur_bounce := 1.9
	var dur_hover := 1.4
	var dur_loop := 0.2
	var mag := 0.13
	
	tween_texture_idle = create_tween().set_loops()
	tween_texture_hover = create_tween().set_loops()
	tween_texture_pulse = create_tween().set_loops()
	
	tween_texture_idle.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_texture_hover.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween_texture_idle.tween_property(texture, "scale", _final_texture_scale * Vector2(1.0+mag,1.0-mag), dur_bounce / 8.0).set_delay(dur_loop)
	tween_texture_idle.tween_property(texture, "scale", _final_texture_scale * Vector2.ONE, dur_bounce).set_trans(Tween.TRANS_ELASTIC)
	
	tween_texture_hover.tween_property(node_texture_2, "position:y", -10.0, dur_hover)
	tween_texture_hover.tween_property(node_texture_2, "position:y", 5.0, dur_hover)
	
	tween_texture_pulse.tween_property(texture, "self_modulate", Color(Color.WHITE * 2.4), 0.05).set_delay(dur_hover)
	tween_texture_pulse.tween_property(texture, "self_modulate", Color(Color.WHITE), 0.8)
	
