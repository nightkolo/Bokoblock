extends Control

@onready var btn: Button = %Button
@onready var character_chibi_boko_2: CharacterChibiBoko = $CharacterChibiBoko2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
	character_chibi_boko_2.pose_happy()
	
	btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://interface/menus/menu_board_select.tscn")
		)
		
	btn.grab_focus()
