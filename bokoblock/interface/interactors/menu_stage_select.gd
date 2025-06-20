class_name BoardSelectScreen
extends MainMenu

signal entered_cb_1()
signal entered_cb_2()

@export var texture_checkerboard_complete_checkmark: Texture = preload("res://assets/interface/checkerboard-complete-checkmark-02.png")
@export var texture_checkerboard_uncomplete_checkmark: Texture = preload("res://assets/interface/checkerboard-uncomplete-checkmark-01.png")

@onready var board_btns: Array[Node] = get_tree().get_nodes_in_group("UIBoardButton")

@onready var back_btn: Button = %BackButton
@onready var btn_b_1: Button = %BtnB1

@onready var reset_popup: Control = %ResetPopup
@onready var progess_btn: Button = %ProgessBtn
@onready var yes_progress_btn: Button = %YesProgressBtn
@onready var no_progress_btn: Button = %NoProgressBtn

@onready var cb_1_check: Node2D = %CB1check
@onready var cb_2_check: Node2D = %CB2check

@onready var cb_1_check_sprite: Sprite2D = %CB1checkSprite
@onready var cb_2_check_sprite: Sprite2D = %CB2checkSprite

var _cb_entered: int = 1


func _ready() -> void:
	display_data()
	
	#### Reset popup
	progess_btn.pressed.connect(func():
		reset_popup.visible = true
		
		no_progress_btn.grab_focus()
		)
	yes_progress_btn.pressed.connect(func():
		GameMgr.reset_game_data()
		
		GameUtil.disable_buttons(btns)
		await get_tree().create_timer(0.2).timeout
		
		display_data()
		reset_popup.visible = false
		
		GameUtil.disable_buttons(btns, false)
		
		progess_btn.grab_focus()
		)
	no_progress_btn.pressed.connect(func():
		reset_popup.visible = false
		
		progess_btn.grab_focus()
		)
	####
	
	is_showing.connect(func():
		btn_b_1.grab_focus()
		
		display_data()
		
		for board_btn: BoardSelectButton in board_btns:
			board_btn.display_data()
		)
	
	back_btn.pressed.connect(func():
		back_button_pressed.emit()
		)
	
	for board_btn: BoardSelectButton in board_btns:
		var board_num := board_btn.name.to_int()
		
		board_btn.pressed.connect(func():
			goto_level(board_num)
			)
			
		if board_num >= 1 && board_num <= 10:
			board_btn.focus_entered.connect(_cb_1_entered)
			board_btn.mouse_entered.connect(_cb_1_entered)
			
		elif board_num >= 11 && board_num <= 20:
			board_btn.focus_entered.connect(_cb_2_entered)
			board_btn.mouse_entered.connect(_cb_2_entered)
		
	btn_b_1.grab_focus()


func goto_level(board_id: int) -> void:
	if Trans.is_transitioning:
		return
	
	Audio.game_start.play()
	
	GameUtil.disable_buttons(board_btns)
	GameUtil.disable_buttons(btns)
	
	GameLogic.self_destruct()
	
	if (board_id >= 1 && board_id <= GameUtil.NUMBER_OF_BOARDS):
		Trans.slide_to_scene(GameUtil.STAGE_FILE_BEGIN + str(board_id) + GameUtil.STAGE_FILE_END)

	else:
		print('"Board CB-' + str(board_id) + '" is non-existent :(')
		GameUtil.disable_buttons(board_btns, false)
		GameUtil.disable_buttons(btns, false)


func display_data() -> void:
	if !GameData.runtime_data.has("101"):
		push_warning("Cannot display data. Key 101 not found in GameData.runtime_data.")
		return
	
	if !GameData.runtime_data.has("102"):
		push_warning("Cannot display data. Key 102 not found in GameData.runtime_data.")
		return
		
	if GameData.runtime_data["101"]["completed"] == true:
		cb_1_check_sprite.texture = texture_checkerboard_complete_checkmark
	else:
		cb_1_check_sprite.texture = texture_checkerboard_uncomplete_checkmark
		
	if GameData.runtime_data["102"]["completed"] == true:
		cb_2_check_sprite.texture = texture_checkerboard_complete_checkmark
	else:
		cb_2_check_sprite.texture = texture_checkerboard_uncomplete_checkmark


func _cb_1_entered() -> void:
	if _cb_entered != 1:
				
		_cb_entered = 1
		entered_cb_1.emit()


func _cb_2_entered() -> void:
	if _cb_entered != 2:
	
		_cb_entered = 2
		entered_cb_2.emit()
