extends Button

@onready var block: Bokoblock = get_parent()

func _ready() -> void:
	pressed.connect(func():
		print(str(block) + " is pressed!"))
