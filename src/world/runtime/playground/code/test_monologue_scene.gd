
extends Control

@onready var monolog_text: MonologText = %MonologText
@onready var boko: CharacterBoko = %Boko


func _process(delta: float) -> void:
	boko.position.x = get_viewport_rect().size.x / 2.0


func _ready() -> void:
	pass
