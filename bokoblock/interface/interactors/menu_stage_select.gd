extends Control
# TODO: make a MainMenus class like previously in Rabbitball, if necessary

@export var texture_checkerboard_complete_checkmark: Texture = preload("res://assets/interface/checkerboard-complete-checkmark-02.png")
@export var texture_checkerboard_uncomplete_checkmark: Texture = preload("res://assets/interface/checkerboard-uncomplete-checkmark-01.png")

@onready var back_btn: Button = %BackButton
@onready var options_btn: Button = %OptionsButton

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")
@onready var board_btns: Array[Node] = get_tree().get_nodes_in_group("UIBoardButton")

@onready var cb_1_check: Node2D = $CB1check
@onready var cb_2_check: Node2D = $CB2check

@onready var cb_1_check_sprite: Sprite2D = %CB1checkSprite
@onready var cb_2_check_sprite: Sprite2D = %CB2checkSprite

@onready var btn_b_1: Button = %BtnB1


func _ready() -> void:
	display_data()
	
	back_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://interface/menus/menu_start.tscn")
		)
	
	options_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://interface/menus/menu_options.tscn")
		)
	
	for board_btn: Button in board_btns:
		board_btn.pressed.connect(func():
			goto_level(board_btn.name.to_int())
			)
	
	btn_b_1.grab_focus()


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
	
	GameUtil.disable_buttons(board_btns)
	GameUtil.disable_buttons(btns)
	
	#await get_tree().create_timer(0.5).timeout
	
	if (board_id >= 1 && board_id <= GameUtil.NUMBER_OF_BOARDS):
		#Audio.game_start.play()
		Trans.slide_to_scene(GameUtil.STAGE_FILE_BEGIN + str(board_id) + GameUtil.STAGE_FILE_END)

	else:
		print('"Board CB-' + str(board_id) + '" is non-existent :(')
		GameUtil.disable_buttons(board_btns, false)
		GameUtil.disable_buttons(btns, false)
		
