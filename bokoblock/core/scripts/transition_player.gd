extends CanvasLayer

@onready var anim: AnimationPlayer = $Anim

## omg, i'm so proud bestie!!
var is_transitioning: bool


func slide_to_next_stage(scene: String) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans1 as Node2D).visible = true
	
	anim.play(&"slide_in", -1, 2.4)
	Audio.lower_higher_music(0.3)
	
	await anim.animation_finished
	
	get_tree().change_scene_to_file(scene)
	
	anim.play(&"slide_out", -1, 2.4)
	
	await anim.animation_finished
	
	($Trans1 as Node2D).visible = false
	is_transitioning = false


func slide_to_credits(speed: float = 1.0) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans3 as Node2D).visible = true
	
	anim.play(&"slide_in_2", -1, speed)
	Audio.lower_higher_music(0.3)
	
	await anim.animation_finished
	
	GameMgr.menu_entered.emit(GameMgr.Menus.CREDITS)
	get_tree().change_scene_to_file("res://interface/menus/main_menus_scene.tscn")
	
	anim.play(&"slide_out_2", -1, 1.0)
	
	await anim.animation_finished
	
	($Trans3 as Node2D).visible = false
	is_transitioning = false


func slide_to_scene(scene: String, speed: float = 1.0) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans3 as Node2D).visible = true
	
	anim.play(&"slide_in_2", -1, speed)
	Audio.lower_higher_music(0.3)
	
	await anim.animation_finished
	
	get_tree().change_scene_to_file(scene)
	
	anim.play(&"slide_out_2", -1, speed)
	
	await anim.animation_finished
	
	($Trans3 as Node2D).visible = false
	is_transitioning = false


func reset_board() -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans2 as Node2D).visible = true
	
	anim.play(&"fade_in", -1, 2.3)
	Audio.lower_higher_music(0.3)
	
	await anim.animation_finished
	
	GameMgr.reset_game()
	
	anim.play(&"fade_out", -1, 2.3)
	
	await anim.animation_finished
	
	($Trans2 as Node2D).visible = false
	is_transitioning = false
