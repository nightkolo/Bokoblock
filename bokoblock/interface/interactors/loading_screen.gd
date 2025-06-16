## @experimental
extends Control
var p: Array = []
var s: String
var load_status
func _ready() -> void:
	s = "res://world/game/levels/stage_1.tscn"
	ResourceLoader.load_threaded_request(s)
func _process(_delta: float) -> void:
	load_status = ResourceLoader.load_threaded_get_status(s, p)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var l_s = ResourceLoader.load_threaded_get(s)
		get_tree().change_scene_to_packed(l_s)
