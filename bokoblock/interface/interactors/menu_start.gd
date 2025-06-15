extends Control

@onready var start_btn: Button = %StartButton

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_start"):
		start_game()


func _ready() -> void:
	start_btn.grab_focus()
	
	start_btn.pressed.connect(start_game)


func start_game() -> void:
	Audio.game_start.play()
	
	start_btn.disabled = true
	GameMgr.self_destruct()
	GameLogic.self_destruct()
	
	Trans.slide_to_scene("res://world/game/levels/stage_0.tscn")
	
