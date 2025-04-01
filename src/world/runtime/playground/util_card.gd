extends CenterContainer

@onready var texture_node: Node2D = $Node2D
@onready var texture: Sprite2D = $Node2D/Texture

var is_highlighted: bool = false
var is_activate: bool = false

var _tween: Tween
var _tween_b: Tween

func _ready() -> void:
	mouse_entered.connect(func():
		print(str(self) + " entered!")
		anim_entered()
		)
	mouse_exited.connect(func():
		print(str(self) + " exited!")
		anim_exited()
		)
	gui_input.connect(func(event: InputEvent):
		if event.is_action_pressed("clicky"):
			is_activate = !is_activate
			print(is_activate)
			anim_bounce()
		)

func anim_bounce() -> void:
	if _tween_b:
		_tween_b.kill()
		
	_tween_b = create_tween()
	_tween_b.set_ease(Tween.EASE_OUT)
	
	texture.scale = Vector2(1.15,0.85 * 1.2)
	_tween_b.tween_property(texture,"scale",Vector2(1.0,1.0 * 1.2),1.3).set_trans(Tween.TRANS_ELASTIC)

func anim_entered() -> void:
	var dur := 0.65
	var scale_to := 1.04
	
	if _tween:
		_tween.kill()
		
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	texture_node.scale = Vector2.ONE * 0.92
	_tween.tween_property(texture_node,"scale:y",scale_to,dur)
	_tween.tween_property(texture_node,"scale:x",scale_to,dur).set_delay(dur/13.33)
	
func anim_exited() -> void:
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	_tween.tween_property(texture_node,"scale",Vector2.ONE,0.15)
