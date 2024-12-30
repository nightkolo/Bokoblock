extends CanvasLayer

@onready var main: MarginContainer = $Main

@onready var has_won_label: Label = %has_wonLabel
@onready var win_checked_label: Label = %"win_checked label"
@onready var are_bodies_moving_label: Label = %"Are_bodies_moving label"
@onready var number_of_bodies_label: Label = %"number_of_bodies label"


func _ready() -> void:
	main.modulate = Color(Color.WHITE, 0.5)


func _process(_delta: float) -> void:
	if visible:
		has_won_label.text = "has_won: " + str(GameLogic.has_won)
		win_checked_label.text = "win_checked: " + str(GameLogic.win_checked)
		are_bodies_moving_label.text = "are_bodies_moving: " + str(GameLogic.are_bodies_moving)
		number_of_bodies_label.text = "number_of_bodies: " + str(GameMgr.number_of_bodies)
	
	else:
		self.set_process(false)
