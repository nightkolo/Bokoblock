extends PointLight2D
class_name StageLight

@warning_ignore("unused_private_class_variable")
var _tween: Tween


func _ready() -> void:
	range_item_cull_mask = 2
