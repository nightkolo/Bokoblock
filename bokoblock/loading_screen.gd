extends Control
var p: Array = []
var s: String
var load_status
func _ready() -> void:
	# Loads s in a seprate thread
	s = "res://world/game/levels/stage_1.tscn"
	ResourceLoader.load_threaded_request(s)
func _process(delta: float) -> void:
	# Get the load status of the s being loaded in the background thread
	load_status = ResourceLoader.load_threaded_get_status(s, p)
	print(p)
	#load_percentage = floorf( lerp(load_percentage, floorf(p[0] * 100.0), 20.0 * delta) )
	#
	#($CenterContainer/Label as Label).text = str(load_percentage) + "%"
	$Sprite2D.rotation += PI * 0.5 * delta
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var l_s = ResourceLoader.load_threaded_get(s)
		get_tree().change_scene_to_packed(l_s)
	#
