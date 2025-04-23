extends Sprite2D


var tween: Tween
var ori_col: Color

func _ready() -> void:
	rotation = deg_to_rad(randf() * 360.0)
	
	ori_col = self_modulate
	anim_pulse()


func _process(delta: float) -> void:
	rotation += deg_to_rad(1.25) * delta
	position = get_viewport_rect().size / 2.0


func anim_pulse() -> void:
	if tween:
		tween.kill()
	
	#var col_to: Color = Color(randf(), randf(), randf()) / 1.5
		
	tween = create_tween()
	#tween = create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	#tween.tween_property(self,"self_modulate",col_to,7.5)
	#tween.tween_property(self,"self_modulate",ori_col,7.5)
	tween.tween_property(self,"self_modulate",ori_col/1.25,7.5)
	tween.tween_property(self,"self_modulate",ori_col,7.5)
	
	await tween.finished
	anim_pulse()
