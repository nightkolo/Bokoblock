class_name TitleScreen
extends MainMenu

signal start_btn_pressed()
signal select_board_btn_pressed()
signal credits_btn_pressed()

@onready var start_btn: Button = %StartButton
@onready var select_stage_btn: Button = %SelectStageButton
@onready var credits_btn: Button = %CreditsButton


func _ready() -> void:
	start_btn.grab_focus()
	
	is_showing.connect(func():
		start_btn.grab_focus()
		)
	
	start_btn.pressed.connect(start_game)
	select_stage_btn.pressed.connect(goto_select_board)
	credits_btn.pressed.connect(goto_credits)


func goto_select_board() -> void:
	select_board_btn_pressed.emit()


func goto_credits() -> void:
	credits_btn_pressed.emit()


func start_game() -> void:
	_disable_buttons(btns)
	GameMgr.self_destruct()
	GameLogic.self_destruct()
	await get_tree().create_timer(0.5).timeout
	
	Trans.slide_to_scene("res://world/game/levels/stage_0.tscn")


func _disable_buttons(p_btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in p_btns:
		btn.disabled = disable
