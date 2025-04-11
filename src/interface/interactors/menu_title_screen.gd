extends Control

@onready var start_btn: Button = %StartButton
@onready var select_stage_btn: Button = %SelectStageButton
@onready var credits_btn: Button = %CreditsButton

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")



func _ready() -> void:
	start_btn.pressed.connect(start_game)
		
	select_stage_btn.pressed.connect(func():
		pass
		)
		
	credits_btn.pressed.connect(func():
		pass
		)
		

func start_game() -> void:
	_disable_buttons(btns)
	GameMgr.self_destruct()
	GameLogic.self_destruct()
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file("res://world/runtime/levels/stage_1.tscn")


func _disable_buttons(p_btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in p_btns:
		btn.disabled = disable
