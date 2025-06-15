extends HBoxContainer

@onready var sfx: Button = %SFX
@onready var music: Button = %Music
@onready var sfx_icon: Sprite2D = $SFX/Node2D/Sprite2D
@onready var music_icon: Sprite2D = $Music/Node2D/Sprite2D


func _ready() -> void:
	music.self_modulate = Color(Color.WHITE, 0.0)
	sfx.self_modulate = Color(Color.WHITE, 0.0)
	
	GameMgr.menu_entered.connect(func(_m: GameMgr.Menus):
		update_options()
		)
	
	sfx.pressed.connect(func():
		var setting := GameMgr.get_game_sfx_muted_setting()
		GameMgr.set_game_sfx_muted(!setting)
		
		update_options()
		)
	music.pressed.connect(func():
		var setting := GameMgr.get_game_music_muted_setting()
		GameMgr.set_game_music_muted(!setting)
		
		update_options()
		)


func update_options() -> void:
	if GameMgr.get_game_sfx_muted_setting():
		sfx_icon.self_modulate = Color(Color.WHITE/2.0, 1.0)
	else:
		sfx_icon.self_modulate = Color(Color.WHITE, 1.0)
	
	if GameMgr.get_game_music_muted_setting():
		music_icon.self_modulate = Color(Color.WHITE/2.0, 1.0)
	else:
		music_icon.self_modulate = Color(Color.WHITE, 1.0)
