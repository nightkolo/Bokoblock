extends Control

@onready var start_btn: Button = %StartButton

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")


func _ready() -> void:
	start_btn.grab_focus()
	
	start_btn.pressed.connect(start_game)


func start_game() -> void:
	start_btn.disabled = true
	GameMgr.self_detruct()
	GameLogic.self_detruct()
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file("res://world/runtime/levels/stage_1.tscn")
