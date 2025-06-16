extends CanvasLayer

@onready var main: MarginContainer = $Main

@onready var labels_container: VBoxContainer = $Main/VBoxContainer

@onready var label: Label = %Label
@onready var label_2: Label = %Label2

@onready var has_won_label: Label = %has_wonLabel
@onready var win_checked_label: Label = %"win_checked label"
@onready var are_bodies_moving_label: Label = %"Are_bodies_moving label"
@onready var number_of_bodies_label: Label = %"number_of_bodies label"
@onready var board_id_label: Label = %"stage_id label"
@onready var world_id_label: Label = %"world_id label"


func _ready() -> void:
	#main.modulate = Color(Color.WHITE, 0.5)
	
	for l: Label in labels_container.get_children():
		l.self_modulate = Color(Color.WHITE, 0.35)
		
	label.self_modulate = Color(Color.WHITE, 0.55)
	label_2.self_modulate = Color(Color.WHITE, 0.55)


func _process(_delta: float) -> void:
	if visible:
		has_won_label.text = "has_won: " + str(GameLogic.has_won)
		win_checked_label.text = "win_checked: " + str(GameLogic.win_checked)
		are_bodies_moving_label.text = "are_bodies_moving: " + str(GameLogic.are_bodies_moving)
		board_id_label.text = "board_id: " + str(GameMgr.board_id)
		world_id_label.text = "WORLD_ID: " + str(GameMgr.checkerboard_id)
	
	
	else:
		self.set_process(false)
