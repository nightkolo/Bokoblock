extends Node2D


@onready var block: Bokoblock = get_parent() as Bokoblock

func _ready() -> void:
	set_process(false)
	#await get_tree().create_timer(1.0).timeout
	#
	#set_process(true)
	

func _process(_delta: float) -> void:
	#t += delta * 0.4
#
	#$Sprite2D.position = $A.position.lerp($B.position, t)
	
	if block.sprite_eyes:
		block.sprite_eyes.position = get_local_mouse_position() / 17.5
		
		block.sprite_eyes.position.y = clamp(block.sprite_eyes.position.y, -5.0, 5.0)
		block.sprite_eyes.position.x = clamp(block.sprite_eyes.position.x, -5.0, 5.0)
		
		
	#print((get_local_mouse_position() / 12.5))
