extends Sprite2D

@export var appear_in: float = 1.5


func _ready() -> void:
	GameLogic.stage_won.connect(func():
		visible = false
		)
	
	modulate = Color(Color.WHITE, 0.0)
	anim_idle()
	
	await get_tree().create_timer(appear_in).timeout
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(Color.WHITE, 1.0),1.0)


func anim_idle() -> void:
	var dur := 2.0
	
	var tween := create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"rotation",deg_to_rad(-10.0),dur/2.0)
	tween.tween_property(self,"rotation",deg_to_rad(10.0),dur/2.0)
