extends Node2D
class_name BokosTopHat

@export var boko: CharacterBoko

var _scale: Vector2

func _ready() -> void:
	if boko:
		_scale = boko.scale


func _process(_delta: float) -> void:
	#global_scale = Vector2.ONE/2.0
	
	global_scale = _scale
