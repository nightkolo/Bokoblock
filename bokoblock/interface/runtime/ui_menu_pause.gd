extends Control
class_name PauseScreen

@onready var bus_SFX: int = AudioServer.get_bus_index("SFX")
@onready var bus_Music: int = AudioServer.get_bus_index("Music")

@onready var resume_btn: Button = %ResumeButton
@onready var reset_btn: Button = %ResetButton
@onready var quit_btn: Button = %ReturnButton

@onready var colorblind_btn: Button = %Areyoucolorblinded
@onready var reduce_motion_btn: Button = %ReduceMotionButton

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
			update_options()
			update_text()
		)
		
	if _gameplay_ui:
		resume_btn.pressed.connect(func():
			_gameplay_ui.pause_or_unpause()
			)
			
		reset_btn.pressed.connect(func():
			_gameplay_ui.reset_stage()
			)
			
		quit_btn.pressed.connect(func():
			_gameplay_ui.allow_input = false
			GameUtil.disable_buttons(btns)
			GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
			
			_gameplay_ui.quit()
			)
	
	reduce_motion_btn.pressed.connect(func():
		var setting := GameMgr.get_reduce_motion_setting()
		GameMgr.set_reduce_motion_setting(!setting)
		
		update_options()
		)
	colorblind_btn.pressed.connect(func():
		var setting := GameMgr.get_colorblind_mode_setting()
		GameMgr.set_colorblind_mode_setting(!setting)
		
		update_options()
		)


func update_options() -> void:
	update_text()
		
	if GameMgr.get_reduce_motion_setting():
		reduce_motion_btn.text = "Reduce Motion: ON"
	else:
		reduce_motion_btn.text = "Reduce Motion: OFF"
		
	if GameMgr.get_colorblind_mode_setting():
		colorblind_btn.text = "Readable Colors: ON"
	else:
		colorblind_btn.text = "Readable Colors: OFF"


func update_text() -> void:
	if GameMgr.get_reduce_motion_setting():
		pause_info.text = GameplayUI.BBCODE_TXT_NO_MOTION + PAUSE_INFO_BEGIN + str(GameMgr.checkerboard_id) + "-" + str(GameMgr.board_id) + PAUSE_INFO_END
	else:
		pause_info.text = GameplayUI.BBCODE_TXT + PAUSE_INFO_BEGIN + str(GameMgr.checkerboard_id) + "-" + str(GameMgr.board_id) + PAUSE_INFO_END
		
