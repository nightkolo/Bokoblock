class_name MainMenu
extends CanvasLayer

signal back_button_pressed()
signal is_showing()

var btns: Array[Node]
var viewport: MarginContainer # Null check needed
var viewport_extra: Node2D # Null check needed


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_cancel"):
		back_button_pressed.emit()


func _init() -> void:
	await ready
	
	add_to_group("MenuScreen")
	btns = get_tree().get_nodes_in_group("UIButton")
	viewport = get_node_or_null("Main")
	viewport_extra = get_node_or_null("Main2")
	
	visibility_changed.connect(func():
		if visible:
			is_showing.emit()
		)


func disable_buttons(list_of_btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in list_of_btns:
		btn.disabled = disable
