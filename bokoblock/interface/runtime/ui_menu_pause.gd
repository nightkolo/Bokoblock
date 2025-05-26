extends Control
class_name PauseScreen

@onready var bus_SFX: int = AudioServer.get_bus_index("SFX")
@onready var bus_Music: int = AudioServer.get_bus_index("Music")

@onready var resume_btn: Button = %ResumeButton
@onready var reset_btn: Button = %ResetButton
@onready var return_btn: Button = %ReturnButton
@onready var sfx_btn: Button = %SFX
@onready var music_btn: Button = %Music
@onready var misc_btn: Button = %Misc

@onready var pause_info: RichTextLabel = %PauseInfo

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")

var _gameplay_ui: GameplayUI

const BBCODE_TXT = "[center][color=#232323][font_size=37][wave amp=10.0 freq=4.0][tornado radius=1.5 freq=1.0]"
const PAUSE_INFO_BEGIN = "=Board "
const PAUSE_INFO_END = " Paused="


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_WHEN_PAUSED
	
	update_text()
	
	if get_parent() is GameplayUI:
		_gameplay_ui = get_parent() as GameplayUI
		
	else:
		push_warning(str(self) + " must be run in GameplayUI,")
		resume_btn.grab_focus()
		get_tree().paused = true
		visible = true
	
	visibility_changed.connect(func():
		if visible:
			resume_btn.grab_focus()
			update_text()
		)
		
	if _gameplay_ui:
		resume_btn.pressed.connect(func():
			_gameplay_ui.pause_or_unpause()
			)
			
		reset_btn.pressed.connect(func():
			_gameplay_ui.reset_stage()
			)
	
	music_btn.pressed.connect(func():
		var muted := GameMgr.is_music_muted
		
		AudioServer.set_bus_mute(bus_Music, !muted)
		
		GameMgr.is_music_muted = !muted
		)
		
	sfx_btn.pressed.connect(func():
		var muted := GameMgr.is_sfx_muted
		
		AudioServer.set_bus_mute(bus_SFX, !muted)
		
		GameMgr.is_sfx_muted = !muted
		)
	
	#return_btn.pressed.connect(func():
		#GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
		#get_tree().paused = false
		#get_tree().change_scene_to_file("res://interface/menus/menu_title_screen.tscn")
		#)


func update_text() -> void:
	pause_info.text = GameplayUI.BBCODE_TXT + PAUSE_INFO_BEGIN + str(GameMgr.current_checkerboard_id) + "-" + str(GameMgr.current_board_id) + PAUSE_INFO_END
