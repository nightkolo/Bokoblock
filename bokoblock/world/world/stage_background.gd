extends CanvasLayer
class_name Background

@export var show_light: bool = true

@onready var texture_bg: TextureRect = %TextureRect
@onready var texture_node: Node2D = %Texture
@onready var texture_node_2: Node2D = %Texture2
@onready var light: Sprite2D = %Light

var tween_turn: Tween


func _ready() -> void:
	_setup_node()
	
	GameMgr.reduce_motion_setting_set.connect(func(is_on: bool):
		if is_on:
			if spin_tween:
				spin_tween.kill()
			
			texture_node.rotation = deg_to_rad(45.0)
			texture_node_2.rotation = 0.0
		else:
			spin_bg()
		)
	PlayerInput.input_turn.connect(anim_turn)
	
	light.visible = show_light


func _setup_node() -> void:
	spin_light()
	
	if GameMgr.get_reduce_motion_setting():
		texture_node.rotation = deg_to_rad(45.0)
	else:
		spin_bg()


func anim_turn(turned_to: float) -> void:
	if GameMgr.get_reduce_motion_setting():
		return
	
	var dur := 0.4
	var mag := 4.0
	
	if tween_turn:
		tween_turn.kill()
		
	tween_turn = create_tween()
	tween_turn.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween_turn.tween_property(texture_node_2, "rotation_degrees", mag * signf(turned_to), dur).as_relative()


func spin_light() -> void:
	var spin_dir: float
	
	light.rotation = deg_to_rad(randf() * 360.0)
	
	await get_tree().create_timer(0.1).timeout
	
	if GameMgr.checkerboard_id == 1:
		light.self_modulate = Color(Color.WHITE, 0.1)
	elif GameMgr.checkerboard_id == 2:
		light.self_modulate = Color(Color.BLACK, 0.1)
	
	if BokoMath.is_even(GameMgr.board_id):
		spin_dir = -1.0
	else:
		spin_dir = 1.0
	
	var tween = create_tween().set_loops()
	tween.tween_property(light,"rotation", PI * spin_dir , 30.0).as_relative()


var spin_tween: Tween

func spin_bg() -> void:
	var spin_dir: float
	
	texture_node.rotation = deg_to_rad(randf() * 360.0)
	
	await get_tree().create_timer(0.1).timeout
	
	if BokoMath.is_even(GameMgr.board_id):
		spin_dir = 1.0
	else:
		spin_dir = -1.0
	
	if spin_tween:
		spin_tween.kill()
	
	spin_tween = create_tween().set_loops()
	
	spin_tween.tween_property(texture_node,"rotation", 0.5 * PI * spin_dir , 30.0).as_relative()
	
