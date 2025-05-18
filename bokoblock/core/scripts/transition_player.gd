extends CanvasLayer

@onready var anim: AnimationPlayer = $Anim

var is_transitioning: bool


func slide_to_next_stage(scene: String) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans1 as Node2D).visible = true
	
	anim.play(&"slide_in", -1, 2.4)
	_lower_music(0.3)
	
	await anim.animation_finished
	
	get_tree().change_scene_to_file(scene)
	
	anim.play(&"slide_out", -1, 2.4)
	
	await anim.animation_finished
	
	($Trans1 as Node2D).visible = false
	is_transitioning = false


func _lower_music(dur: float = 1.0):
	var original_db = Audio.music_stage.volume_db
	var tween = create_tween()
	
	tween.tween_property(Audio.music_stage, "volume_db", original_db-15.0, dur)
	tween.tween_property(Audio.music_stage, "volume_db", original_db, dur).set_delay(dur)
