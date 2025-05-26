extends CanvasLayer

@onready var anim: AnimationPlayer = $Anim

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
