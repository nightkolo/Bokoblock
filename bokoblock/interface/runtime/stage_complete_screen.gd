extends Control
class_name StageCompleteScreen

@onready var stage_complete_info: RichTextLabel = %StageCompleteInfo

@onready var bg: ColorRect = $BG
@onready var node_star: Node2D = %StarNode
@onready var node_star_2: Node2D = %StarNode2
@onready var texture_star: Sprite2D = %Star
@onready var panel: NinePatchRect = %Panel

@onready var next_stage_button: Button = %NextStageButton

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")

var _gameplay_ui: GameplayUI

const BBCODE_TXT = "[center][color=#232323][font_size=37][wave amp=10.0 freq=4.0][tornado radius=1.5 freq=1.0]"
const _INFO_BEGIN = "Stage "
const _INFO_END = " Completed"


func _ready() -> void:
	update_text()
	
	texture_star.scale = Vector2.ONE * 0.7
	
	if get_parent() is GameplayUI:
		_gameplay_ui = get_parent() as GameplayUI
		
	else:
		push_warning(str(self) + " must be run in GameplayUI,")
		next_stage_button.grab_focus()
		get_tree().paused = true
		visible = true
	
	visibility_changed.connect(func():
		if visible:
			next_stage_button.grab_focus()
			update_text()
		)
		
	next_stage_button.pressed.connect(func():
		GameMgr.goto_next_stage()
		)
	

var _tween_open: Tween
var _tween_star: Tween



func anim_open():
	visible = true
	
	anim_star()
	
	var dur := 2.0
	var delay := dur / 12.0
	
	_tween_open = create_tween().set_parallel(true)
	_tween_open.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	panel.pivot_offset = Vector2( panel.size.x / 2 , panel.size.y)
	panel.scale = Vector2.ZERO
	
	_tween_open.tween_property(panel, "scale:y", 1.0, dur)
	_tween_open.tween_property(panel, "scale:x", 1.0, dur).set_delay(delay)
	
	
func anim_star():
	var dur := 0.85
	
	texture_star.position.x -= 400.0
	texture_star.scale = Vector2.ONE * 2.0
	node_star.rotation = 3 * PI
	
	_tween_star = create_tween().set_parallel(true)
	
	_tween_star.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	
	_tween_star.tween_property(texture_star, "position", Vector2.ZERO, dur)
	_tween_star.tween_property(node_star_2, "scale", Vector2.ZERO, dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	_tween_star.tween_property(texture_star, "scale", Vector2.ONE * 0.7, dur)
	_tween_star.tween_property(bg, "color", Color(Color.BLACK, 0.5), dur)
	
	_tween_star.tween_property(node_star, "rotation", 0.0, dur)
	await get_tree().create_timer(dur).timeout
	anim_star_bounce(dur)
	

func anim_star_bounce(dur: float):
	if _tween_star:
		_tween_star.kill()
	
	($StarNode/Particles as CPUParticles2D).emitting = true 
	
	bg.color = Color(Color.WHITE, 0.8)
	
	_tween_star = create_tween().set_parallel(true)
	_tween_star.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	node_star_2.scale = -Vector2.ONE * 0.5
	
	_tween_star.tween_property(node_star_2, "scale", Vector2.ONE, dur*4.0)
	_tween_star.tween_property(bg, "color", Color(Color.WHITE, 0.2), dur/4.0).set_trans(Tween.TRANS_LINEAR)
	get_tree().create_timer(dur).timeout
	anim_star_idle()

var _tween_star_idle: Tween
var _tween_star_hover: Tween
var _tween_star_pulse: Tween


func anim_star_idle():
	var dur := 1.75
	var loop_dur := 0.2
	var mag := 0.2
	
	_tween_star_idle = create_tween().set_loops()
	_tween_star_hover = create_tween().set_loops()
	_tween_star_pulse = create_tween().set_loops()
	
	_tween_star_idle.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_star_hover.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	_tween_star_idle.tween_property(node_star_2, "scale", Vector2(1.0+mag,1.0-mag), dur / 8.0).set_delay(loop_dur)
	_tween_star_idle.tween_property(node_star_2, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	
	_tween_star_hover.tween_property(node_star_2, "position:y", -10.0, 1.5)
	_tween_star_hover.tween_property(node_star_2, "position:y", 5.0, 1.5)
	

func update_text() -> void:
	stage_complete_info.text = BBCODE_TXT + _INFO_BEGIN + str(GameMgr.current_world_id) + "-" + str(GameMgr.current_stage_id) + _INFO_END
