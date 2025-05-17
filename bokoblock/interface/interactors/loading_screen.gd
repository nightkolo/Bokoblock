extends Control

var progress: Array = []
var scene: String
var load_status
var load_percentage: float


func _ready() -> void:
	# Loads scene in a seprate thread
	scene = "res://world/game/levels/stage_1.tscn"
	
	ResourceLoader.load_threaded_request(scene)
	
	
	
func _process(delta: float) -> void:
	# Get the load status of the scene being loaded in the background thread
	load_status = ResourceLoader.load_threaded_get_status(scene, progress)
	
	print(progress)
	
	load_percentage = floorf( lerp(load_percentage, floorf(progress[0] * 100.0), 20.0 * delta) )
	#
	($CenterContainer/Label as Label).text = str(load_percentage) + "%"
	

	
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		
		var l_scene = ResourceLoader.load_threaded_get(scene)
		
		get_tree().change_scene_to_packed(l_scene)
	#
