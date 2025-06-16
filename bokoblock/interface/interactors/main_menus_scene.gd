## UI code.
class_name MainMenusUI
extends Control

enum MainMenus {
	TITLE = 0,
	BOARD_SELECT = 1,
	CREDITS = 2
}

@export var transition_time: float = 0.7

@onready var menus: Array[Node] = get_tree().get_nodes_in_group("MenuScreen")

@onready var ui_cam: Camera2D = $UICam
@onready var ui_bg: UIBackground = $BG

@onready var menu_title: TitleScreen = $TitleScreen
@onready var menu_credits: CreditsScreen = $MenuCredits
@onready var menu_board_select: BoardSelectScreen = $MenuStageSelect

#### Juice

@onready var checkerboard_main: TileMapLayer = %Checkerboard
@onready var checkerboard_1: TileMapLayer = %Checkerboard1
@onready var checkerboard_2: TileMapLayer = %Checkerboard2

@onready var bokobody: Bokobody = %Bokobody

@onready var title_area: Area2D = %TitleArea
@onready var credit_area: Area2D = %CreditArea

@onready var onscreen: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

####

var _tween_cam: Tween
var _tween_fade_out: Tween
var _tween_fade_in: Tween
var _tween_spin: Tween
var _tween_bg: Tween
var _tween_cb: Tween


func _ready() -> void:
	GameMgr.current_menu = self
	
	if GameMgr.menu_id == GameMgr.Menus.CREDITS: # For the game's ending
		enter_main_menu(MainMenus.CREDITS)
		
	else:
		enter_main_menu(MainMenus.TITLE)
		GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
	
	menu_title.start_btn.grab_focus()
	
	menu_title.select_board_btn_pressed.connect(func():
		enter_main_menu(MainMenus.BOARD_SELECT)
		GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
		
		menu_board_select.display_data()
		)
	
	menu_title.credits_btn_pressed.connect(func():
		enter_main_menu(MainMenus.CREDITS)
		
		if GameData.medal_data.has("curiosity") && GameMgr.current_medal_notifier:
			if GameData.medal_data["curiosity"] == false: 
				GameMgr.current_medal_notifier.anim_medal_unlocked()
			
		await MedalMgr.unlock_a_medal("curiosity", NewgroundsIds.MedalId.Curiosity)
		)
	
	for menu: MainMenu in menus:
		menu.back_button_pressed.connect(func():
			enter_main_menu(MainMenus.TITLE)
			GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
		)
	
	_apply_ui_juice()


func enter_main_menu(p_menu: MainMenus) -> void:
	if p_menu == MainMenus.TITLE: # Hack.
		_setup_bokobody()
	
	enter_menu(p_menu)
	trans_cam_to_menu_pos(p_menu)
	color_to_menu(p_menu)


func color_to_menu(p_menu: MainMenus) -> void:
	if _tween_bg:
		_tween_bg.kill()
	_tween_bg = get_tree().create_tween().set_parallel(true)
	
	ui_bg.node_texture_1.rotation_degrees = 180.0
	
	match p_menu:
		
		MainMenus.TITLE:
			ui_bg.node_texture_1.rotation_degrees = -180.0
			
			_tween_bg.tween_property(ui_bg.texture_bg, "self_modulate", Color(0.22, 0.22, 0.35), transition_time)
			_tween_bg.tween_property(checkerboard_main, "self_modulate", Color(0.7, 0.7, 0.735), transition_time)

		MainMenus.BOARD_SELECT:
			_tween_bg.tween_property(ui_bg.texture_bg, "self_modulate", Color(0.45, 0.25, 0.45), transition_time)
			
		MainMenus.CREDITS:
			_tween_bg.tween_property(ui_bg.texture_bg, "self_modulate", Color(0.3, 0.3, 0.3), transition_time)
			_tween_bg.tween_property(checkerboard_main, "self_modulate", Color(Color.WHITE/2.0, 1.0), transition_time)
			
		_:
			pass
	
	if _tween_spin:
		_tween_spin.kill()
		
	_tween_spin = get_tree().create_tween()
	_tween_spin.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	_tween_spin.tween_property(ui_bg.node_texture_1, "rotation", 0.0, transition_time*2.0)
	

func enter_menu(p_menu: MainMenus) -> void:
	_disable_menu_buttons(menus)
	
	await _anim_fade_out()
	_reset_tween_fade_in()
	_tween_fade_in = get_tree().create_tween()
	
	match p_menu:
		
		MainMenus.TITLE:
			menu_title.show()
			menu_title.visible = true
			_tween_fade_in.tween_property(menu_title.viewport,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
			if menu_title.viewport_extra:
				_tween_fade_in.tween_property(menu_title.viewport_extra,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)

		MainMenus.BOARD_SELECT:
			menu_board_select.show()
			menu_board_select.visible = true
			_tween_fade_in.tween_property(menu_board_select.viewport,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
			if menu_board_select.viewport_extra:
				_tween_fade_in.tween_property(menu_board_select.viewport_extra,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
		MainMenus.CREDITS:
			menu_credits.show()
			menu_credits.visible = true
			_tween_fade_in.tween_property(menu_credits.viewport,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
			if menu_credits.viewport_extra:
				_tween_fade_in.tween_property(menu_credits.viewport_extra,"modulate",Color(Color.WHITE,1.0),transition_time/2.0)
			
		_:
			pass
			
	_disable_menu_buttons(menus, false)


func trans_cam_to_menu_pos(p_menu: MainMenus) -> void:
	#Audio.main_menu_trans.play()
	match p_menu:
		
		MainMenus.TITLE:
			_anim_move_cam(Vector2.ZERO)
		
		MainMenus.BOARD_SELECT:
			_anim_move_cam(Vector2(0.0, 720.0))
			
		MainMenus.CREDITS:
			_anim_move_cam(Vector2(960.0, 0.0))


func _anim_fade_out() -> void:
	_reset_tween_fade_out()
	_tween_fade_out = get_tree().create_tween().set_parallel(true)
	_tween_fade_out.tween_property(menu_title.viewport,"modulate",Color(Color.WHITE,0.0),transition_time/2.0)
	_tween_fade_out.tween_property(menu_board_select.viewport,"modulate",Color(Color.WHITE,0.0),transition_time/2.0)
	_tween_fade_out.tween_property(menu_credits.viewport,"modulate",Color(Color.WHITE,0.0),transition_time/2)
	
	if menu_credits.viewport_extra:
		_tween_fade_out.tween_property(menu_credits.viewport_extra,"modulate",Color(Color.WHITE,0.0),transition_time/2)
	
	if menu_title.viewport_extra:
		_tween_fade_out.tween_property(menu_title.viewport_extra,"modulate",Color(Color.WHITE,0.0),transition_time/2)
	
	if menu_board_select.viewport_extra:
		_tween_fade_out.tween_property(menu_board_select.viewport_extra,"modulate",Color(Color.WHITE,0.0),transition_time/2)

	await _tween_fade_out.finished
	for menu: MainMenu in menus:
		menu.hide()
		menu.visible = false


func _anim_move_cam(move_to: Vector2) -> void:
	_reset_tween_cam()
	_tween_cam = get_tree().create_tween()
	_tween_cam.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween_cam.tween_property(ui_cam,"global_position",move_to,transition_time)


func _disable_menu_buttons(p_menus: Array[Node], disable: bool = true) -> void:
	for menu: MainMenu in p_menus:
		for btn: Button in menu.btns:
			btn.disabled = disable


func _reset_tween_cam() -> void:
	if _tween_cam != null:
		_tween_cam.kill()
		
		
func _reset_tween_fade_out() -> void:
	if _tween_fade_out != null:
		_tween_fade_out.kill()
		

func _reset_tween_fade_in() -> void:
	if _tween_fade_in != null:
		_tween_fade_in.kill()


var tween_text: Tween

func _apply_ui_juice() -> void:
	# NOTE: This is all very hacky code.
	bokobody.no_move = false
	
	_setup_bokobody()
	
	PlayerInput.input_move.connect(func(move_to: Vector2):
		if onscreen.is_on_screen():
			bokobody.move(move_to)
		)
		
	PlayerInput.input_turn.connect(func(turn_to: float):
		if onscreen.is_on_screen():
			bokobody.turn(turn_to)
			
			menu_credits.kolo.pivot_offset = menu_credits.kolo.size / 2.0
			menu_credits.kolo.rotation_degrees = 180.0 * -turn_to
			
			if tween_text:
				tween_text.kill()
			
			tween_text = create_tween()
			tween_text.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			tween_text.tween_property(menu_credits.kolo, "rotation_degrees", 0.0, 0.4)
		)
	
	# TODO: Make board select screen seperate in GameMgr.Menus.
	# For now, I cost-cutted.
	GameMgr.menu_entered.connect(func(_entered: GameMgr.Menus):
		_setup_bokobody()
		)
	
	title_area.area_entered.connect(func(area: Area2D):
		if area is Bokoblock && GameMgr.menu_id == GameMgr.Menus.CREDITS:
			enter_main_menu(MainMenus.TITLE)
			GameMgr.menu_entered.emit(GameMgr.Menus.MENUS)
			
			if GameData.medal_data.has("halls") && GameMgr.current_medal_notifier:
				if GameData.medal_data["halls"] == false: 
					GameMgr.current_medal_notifier.anim_medal_unlocked()
				
			await MedalMgr.unlock_a_medal("halls", NewgroundsIds.MedalId.RunningInTheHalls)
		)
	
	credit_area.area_entered.connect(func(area: Area2D):
		if area is Bokoblock && GameMgr.menu_id == GameMgr.Menus.MENUS:
			enter_main_menu(MainMenus.CREDITS)
			GameMgr.menu_entered.emit(GameMgr.Menus.CREDITS)
			)
	
	menu_board_select.entered_cb_1.connect(func():
		if _tween_cb:
			_tween_cb.kill()
			
		_tween_cb = create_tween().set_parallel(true)
		_tween_cb.tween_property(checkerboard_1, "self_modulate", Color(Color.WHITE/1.25, 1.0), 0.2)
		_tween_cb.tween_property(checkerboard_2, "self_modulate", Color(Color.WHITE/1.65, 1.0), 0.2)
		)
		
	menu_board_select.entered_cb_2.connect(func():
		if _tween_cb:
			_tween_cb.kill()
			
		_tween_cb = create_tween().set_parallel(true)
		_tween_cb.tween_property(checkerboard_2, "self_modulate", Color(Color.WHITE/1.25, 1.0), 0.2)
		_tween_cb.tween_property(checkerboard_1, "self_modulate", Color(Color.WHITE/1.65, 1.0), 0.2)
		)


func _setup_bokobody() -> void:
	GameLogic.self_destruct()
	GameLogic.current_bodies.append(bokobody)
