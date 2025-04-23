extends VBoxContainer

@export_multiline var bbcode_default: String = "[center][font_size=24.0]"

@onready var child_labels: Array[Node] = get_children()


func _ready() -> void:
	set_global_bbcode()
	

func set_global_bbcode() -> void:
	if child_labels.size() == 0:
		return
	
	for label: RichTextLabel in child_labels:
		var text := label.text
		label.text = bbcode_default + text
