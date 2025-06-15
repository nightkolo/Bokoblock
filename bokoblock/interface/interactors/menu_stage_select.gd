class_name BoardSelectScreen
extends MainMenu

signal entered_cb_1()
signal entered_cb_2()

@export var texture_checkerboard_complete_checkmark: Texture = preload("res://assets/interface/checkerboard-complete-checkmark-02.png")
@export var texture_checkerboard_uncomplete_checkmark: Texture = preload("res://assets/interface/checkerboard-uncomplete-checkmark-01.png")

@onready var back_btn: Button = %BackButton
@onready var btn_b_1: Button = %BtnB1

@onready var board_btns: Array[Node] = get_tree().get_nodes_in_group("UIBoardButton")

@onready var cb_1_check: Node2D = $CB1check
@onready var cb_2_check: Node2D = $CB2check

@onready var cb_1_check_sprite: Sprite2D = %CB1checkSprite
@onready var cb_2_check_sprite: Sprite2D = %CB2checkSprite

var _cb_entered: int = 1


func _ready() -> void:
	display_data()
	
	is_showing.connect(func():
		btn_b_1.grab_focus()
		
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


func _cb_1_entered() -> void:
	if _cb_entered != 1:
				
		_cb_entered = 1
		entered_cb_1.emit()


func _cb_2_entered() -> void:
	if _cb_entered != 2:
	
		_cb_entered = 2
		entered_cb_2.emit()


func display_data() -> void:
	if !GameData.runtime_data.has("101"):
		push_warning("Cannot display data. Keys 101 not found in GameData.runtime_data.")
		return
	
	if !GameData.runtime_data.has("102"):
		push_warning("Cannot display data. Keys 102 not found in GameData.runtime_data.")
		return
		
	if GameData.runtime_data["101"]["completed"]:
		cb_1_check_sprite.texture = texture_checkerboard_complete_checkmark
	else:
		cb_1_check_sprite.texture = texture_checkerboard_uncomplete_checkmark
		
	if GameData.runtime_data["102"]["completed"]:
		cb_2_check_sprite.texture = texture_checkerboard_complete_checkmark
	else:
		cb_2_check_sprite.texture = texture_checkerboard_uncomplete_checkmark


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
		
