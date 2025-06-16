## @deprecated
extends Control

@onready var music_btn: Button = %MusicBtn
@onready var sfx_btn: Button = %SFXBtn
@onready var progess_btn: Button = %ProgessBtn
@onready var back_button: Button = %BackButton

@onready var yes_progress_btn: Button = %YesProgressBtn

@onready var no_progress_btn: Button = %NoProgressBtn


func _ready() -> void:
	update_text()
	
	back_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://interface/menus/menu_board_select.tscn")
		)
	
	progess_btn.pressed.connect(func():
		$ResetPopup.visible = true
		$MarginContainer.visible = false
		
		%NoProgressBtn.grab_focus()
		)
	yes_progress_btn.pressed.connect(func():
		GameMgr.reset_game_data()
		
		$ResetPopup.visible = false
		$MarginContainer.visible = true
		
		music_btn.grab_focus()
		)
	no_progress_btn.pressed.connect(func():
		$ResetPopup.visible = false
		$MarginContainer.visible = true
		
		music_btn.grab_focus()
		)
	
	sfx_btn.pressed.connect(func():
		var setting := GameMgr.get_game_sfx_muted_setting()
		GameMgr.set_game_sfx_muted(!setting)
		
		update_text()
		)
	music_btn.pressed.connect(func():
		var setting := GameMgr.get_game_music_muted_setting()
		GameMgr.set_game_music_muted(!setting)
		
		update_text()
		)
		
	music_btn.grab_focus()


func update_text() -> void:
	if GameMgr.get_game_sfx_muted_setting():
		sfx_btn.text = "Sounds: OFF"
	else:
		sfx_btn.text = "Sounds: ON"
	
	if GameMgr.get_game_music_muted_setting():
		music_btn.text = "Music: OFF"
	else:
		music_btn.text = "Music: ON"
	
