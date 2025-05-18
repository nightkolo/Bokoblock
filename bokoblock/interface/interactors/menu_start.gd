extends Control

@onready var start_btn: Button = %StartButton

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")


func _ready() -> void:
	start_btn.grab_focus()
	
	start_btn.pressed.connect(start_game)


func start_game() -> void:
	var scene = preload("res://world/game/levels/stage_1.tscn")
	
	start_btn.disabled = true
	GameMgr.self_destruct()
	GameLogic.self_destruct()
	
	get_tree().change_scene_to_packed(scene)
	#get_tree().change_scene_to_file("res://interface/menus/menu_title_screen.tscn")
	
