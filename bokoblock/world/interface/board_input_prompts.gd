extends Node2D

@export var appear_in: float = 0.5
@export var top_hat_man: BoardInfo

func _ready() -> void:
	GameLogic.stage_won.connect(func():
		var tween_b = create_tween()
		
		tween_b.tween_property(self,"modulate",Color(Color(1.0 , 0.79, 1.0), 0.0),1.0)
		)
	
	modulate = Color(Color(1.0 , 0.79, 1.0), 0.0)
	
	if top_hat_man:
		await top_hat_man.letter_showing_finished
	else:
		await get_tree().create_timer(appear_in).timeout
	
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(Color(1.0 , 0.79, 1.0), 1.0),1.0)
