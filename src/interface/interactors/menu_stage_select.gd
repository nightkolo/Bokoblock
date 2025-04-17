extends Control
# TODO: make a MainMenus class like previously in Rabbitball, if necessary

@onready var back_btn: Button = %BackButton

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")


func _ready() -> void:
	back_btn.grab_focus()
	
	back_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://interface/menus/menu_title_screen.tscn")
		)
