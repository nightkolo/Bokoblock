extends Node2D
class_name ChibiBokosTopHat

@export var parent: Node2D

var s: Vector2


func _ready() -> void:
	s = parent.scale


func _process(_delta: float) -> void:
	global_scale = s
