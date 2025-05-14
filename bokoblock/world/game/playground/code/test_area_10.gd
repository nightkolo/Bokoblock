## @deprecated
##
## Mock-up Level code.
extends Node2D
class_name MemeStage

@export var auto_assign_ids: bool = true ## Doesn't do anything
@export var stage_id: int = -1: ## Doesn't do anything either
	get:
		return stage_id
	set(value):
		GameMgr.current_stage_id = value
		stage_id = value
@export var checkboard_id: int = -1: ## Doesn't do anything either
	get:
		return checkboard_id
	set(value):
		GameMgr.current_checkerboard_id = value
		checkboard_id = value
@export_group("Modify")
@export var win_condition: GameLogic.WinCondition ## Doesn't do anything
@export var stage_progression: bool = false ## Doesn't do anything either
@export_group("Miscellanous")
@export var show_dev_ui: bool = false ## Doesn't do anything

@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	GameLogic.has_won = true
	canvas_layer.visible = true

	print_rich("[font_size=60][b][rainbow][wave]Look At Him 🥺🥺🥺🥺🥺")
	print_rich("[font_size=60][b][rainbow][wave]Look At Him 🥺🥺🥺🥺🥺")
	print_rich("[font_size=60][b][rainbow][wave]Look At Him 🥺🥺🥺🥺🥺")
	print_rich("[font_size=60][b][rainbow][wave]Look At Him 🥺🥺🥺🥺🥺")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("clicky"):
		print_rich("[font_size=60][b][rainbow][wave]Look At Him 🥺🥺🥺🥺🥺")
