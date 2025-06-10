class_name MainMenu
extends CanvasLayer

signal back_button_pressed()
signal is_showing()

var btns: Array[Node]
var viewport: MarginContainer


func _init() -> void:
	await ready
	
	add_to_group("MenuScreen")
	btns = get_tree().get_nodes_in_group("UIButton")
	viewport = get_node_or_null("Main")
	
	visibility_changed.connect(func():
		if visible:
			is_showing.emit()
		)


func disable_buttons(list_of_btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in list_of_btns:
		btn.disabled = disable
