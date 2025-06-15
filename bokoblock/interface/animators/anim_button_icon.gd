extends Button

var tween: Tween

var node_sprite: Node2D
var sprite: Sprite2D

func _ready() -> void:
	pivot_offset = size / 2
	
	self_modulate = Color(Color.WHITE, 0.0)
	custom_minimum_size = Vector2.ONE * 50.0
	
	node_sprite = get_node_or_null("Node2D")
	sprite = get_node_or_null("Node2D/Sprite2D")
	
	mouse_entered.connect(anim_entered)
	mouse_exited.connect(anim_exited)
	focus_entered.connect(anim_entered)
	focus_exited.connect(anim_exited)


func anim_entered() -> void:
	var dur := 1.0
	var scale_to := 1.2
	
	Audio.ui_button_hover.play()
	
	if node_sprite:
		node_sprite.self_modulate = Color(Color.WHITE*1.2)
	
		if tween:
			tween.kill()

		tween = create_tween().set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(node_sprite, "scale:x", scale_to, dur/3).set_trans(Tween.TRANS_BACK)
		tween.tween_property(node_sprite, "scale:y", scale_to, dur).set_trans(Tween.TRANS_ELASTIC).set_delay(dur/9)
		
		
func anim_exited() -> void:
	if node_sprite:
		if tween:
			tween.kill()
		
		node_sprite.self_modulate = Color(Color.WHITE*1.0)
		
		tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(node_sprite, "scale", Vector2.ONE, 0.9)
	
