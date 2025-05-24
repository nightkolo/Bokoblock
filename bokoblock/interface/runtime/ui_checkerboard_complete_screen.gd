extends Control
class_name CheckerboardCompleteScreen

@onready var stage_complete_info: RichTextLabel = %StageCompleteInfo

@onready var bg: ColorRect = $BG
@onready var node_star: Node2D = %StarNode
@onready var node_star_2: Node2D = %StarNode2
@onready var texture_star: Sprite2D = %Star
@onready var panel: NinePatchRect = %Panel

@onready var next_stage_button: Button = %NextStageButton

#@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")

var _gameplay_ui: GameplayUI

const BBCODE_TXT = "[center][color=#232323][font_size=37][wave amp=10.0 freq=4.0][tornado radius=1.5 freq=1.0]"
const _INFO_BEGIN = "=Checkerboard "
const _INFO_END = " Completed="

var t_panel: Tween
var t_star_spinning: Tween
var t_star_idle_bounce: Tween
var t_star_idle_hover: Tween
#var t_star_pulse: Tween
var t_star_landed: Tween


# TODO: stop using types all the time when you're debugging :)

func _ready() -> void:
	update_text()
	
	texture_star.scale = Vector2.ONE * 0.7
	
	if get_parent() is GameplayUI:
		_gameplay_ui = get_parent() as GameplayUI
		
	else:
		push_warning(str(self) + " must be run under GameplayUI.")
		next_stage_button.grab_focus()
		get_tree().paused = true
		visible = true
	
	visibility_changed.connect(func():
		if visible:
			next_stage_button.grab_focus()
			#update_text()
		)
		
	next_stage_button.pressed.connect(func():
		if t_star_idle_bounce:
			t_star_idle_bounce.kill()
		
		if t_star_idle_hover:
			t_star_idle_hover.kill()
		
		GameMgr.goto_next_checkerboard()
		)


func open():
	GameMgr.menu_entered.emit(GameMgr.GameMenus.CHECKERBOARD_COMPLETE)
	visible = true
	
	update_text()
	anim_open()


func update_text() -> void:
	stage_complete_info.text = BBCODE_TXT + _INFO_BEGIN + str(GameMgr.current_checkerboard_id) + _INFO_END


func anim_open():
	anim_star_spinning()
	
	var dur := 2.0
	var delay := dur / 12.0
	
	t_panel = create_tween().set_parallel(true)
	t_panel.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	panel.pivot_offset = Vector2(panel.size.x / 2.0, panel.size.y)
	panel.scale = Vector2.ZERO
	
	t_panel.tween_property(panel, "scale:y", 1.0, dur)
	t_panel.tween_property(panel, "scale:x", 1.0, dur).set_delay(delay)
	
	
func anim_star_spinning():
	var dur := 0.75
	
	texture_star.position.x -= 400.0
	texture_star.scale = Vector2.ONE * 2.0
	node_star.rotation = 3 * PI
	
	t_star_spinning = create_tween().set_parallel(true)
	
	t_star_spinning.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	
	t_star_spinning.tween_property(texture_star, "position", Vector2.ZERO, dur)
	t_star_spinning.tween_property(node_star_2, "scale", Vector2.ZERO, dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	t_star_spinning.tween_property(texture_star, "scale", Vector2.ONE * 0.6, dur)
	t_star_spinning.tween_property(bg, "color", Color(Color.BLACK, 0.5), dur)
	
	t_star_spinning.tween_property(node_star, "rotation", 0.0, dur)
	await get_tree().create_timer(dur).timeout
	anim_star_landed(dur)
	

func anim_star_landed(dur: float):
	if t_star_landed:
		t_star_landed.kill()
	
	($StarNode/Particles as CPUParticles2D).emitting = true 
	
	bg.color = Color(Color.WHITE, 0.8)
	
	t_star_landed = create_tween().set_parallel(true)
	t_star_landed.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	node_star_2.scale = -Vector2.ONE * 0.5
	
	t_star_landed.tween_property(node_star_2, "scale", Vector2.ONE, dur*4.0)
	t_star_landed.tween_property(bg, "color", Color(Color.WHITE, 0.2), dur/4.0).set_trans(Tween.TRANS_LINEAR)
	#get_tree().create_timer(dur).timeout
	anim_star_idle()


func anim_star_idle():
	var dur := 1.75
	var loop_dur := 0.2
	var mag := 0.1
	
	t_star_idle_bounce = create_tween().set_loops()
	t_star_idle_hover = create_tween().set_loops()
	#t_star_pulse = create_tween().set_loops()
	
	t_star_idle_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t_star_idle_hover.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	t_star_idle_bounce.tween_property(node_star_2, "scale", Vector2(1.0+mag,1.0-mag), dur / 8.0).set_delay(loop_dur)
	t_star_idle_bounce.tween_property(node_star_2, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	
	t_star_idle_hover.tween_property(node_star_2, "position:y", -10.0, 1.5)
	t_star_idle_hover.tween_property(node_star_2, "position:y", 5.0, 1.5)
