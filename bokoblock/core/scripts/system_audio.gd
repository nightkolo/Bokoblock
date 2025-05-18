## Audio system
##
## Under construction
extends Node

@onready var bus_GameSound: int = AudioServer.get_bus_index("GameSound")

#var music_menu: AudioStreamPlayer ## @experimental
@onready var music_stage: AudioStreamPlayer = $Music/StageMusic

#@onready var game_paused: AudioStreamPlayer = $UI/GamePaused
@onready var game_reset_01: AudioStreamPlayer = $UI/GameReset01
@onready var game_reset_02: AudioStreamPlayer = $UI/GameReset02
#@onready var game_start: AudioStreamPlayer = $UI/GameStart
#@onready var menu_exit: AudioStreamPlayer = $UI/MenuExit
@onready var stage_next: AudioStreamPlayer = $UI/StageNext
@onready var stage_win: AudioStreamPlayer = $UI/StageWin

@onready var body_turn_1: AudioStreamPlayer = $SFX/BlockTurn1
@onready var body_turn_2: AudioStreamPlayer = $SFX/BlockTurn2

#@onready var body_turning_sound: AudioStreamPlayer = $SFX/BlockTurningSound

@onready var body_turn_hit_1: AudioStreamPlayer = $SFX/BlockTurnHit
@onready var body_turn_hit_2: AudioStreamPlayer = $SFX/BlockTurnHit2
@onready var body_move_hit_1: AudioStreamPlayer = $SFX/BlockMoveHit
@onready var body_move_hit_2: AudioStreamPlayer = $SFX/BlockMoveHit2

@onready var one_color_wall_exit: AudioStreamPlayer = $SFX/OneColorWallExit
@onready var one_color_wall_enter: AudioStreamPlayer = $SFX/OneColorWallEnter
@onready var one_color_wall_hit: AudioStreamPlayer = $SFX/OneColorWallHit

#@onready var body_happy_01: AudioStreamPlayer = $SFX/BodyHappy01
#@onready var body_happy_02: AudioStreamPlayer = $SFX/BodyHappy02

var body_moving: Array[Node]
var body_turn_click: Array[Node]
var _stage_complete_jingles: Array[Node]

#var _menu_enter_jingles: Array[Node]
var _reset_sound: bool = true


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	_stage_complete_jingles = $UI/MenuEnterJingles.get_children()
	body_moving = $SFX/BodyMoving.get_children()
	body_turn_click = $SFX/BodyTurnClick.get_children()
	
	GameMgr.game_entered.connect(func(entered: bool):
		AudioServer.set_bus_mute(bus_GameSound, !entered)
		
		if entered:
			if !music_stage.playing:
				music_stage.play()
		else:
			music_stage.stop()
	)
		
	# TODO: Maybe should not make everything global
	
	GameMgr.game_reset.connect(func() -> void:
		_reset_sound = !_reset_sound
		
		if _reset_sound:
			game_reset_01.play()
		else:
			game_reset_02.play()
		)
		
	GameMgr.game_just_ended.connect(func():
		stage_win.play()
		)
		
	GameMgr.game_end.connect(func():
		stage_next.play()
		)
	
	GameLogic.state_checked.connect(func(_have_moved: bool):
		_check_game_state()
		)
	
	GameLogic.body_hit_move.connect(play_body_move_hit)
	GameLogic.body_hit_turn.connect(play_body_turn_hit)
	
	PlayerInput.input_move.connect(func(_move_to: Vector2):
		play_body_move()
		)
	PlayerInput.input_turn.connect(play_body_turn)

	await get_tree().create_timer(0.1).timeout
	if GameMgr.current_ui_handler:
		GameMgr.current_ui_handler.game_pause_toggled.connect(func(_is_paused: bool):
			# TODO: lower music volume
			pass
			)


func _check_game_state() -> void:
	pass


func play_body_move() -> void:
	var aud: AudioStreamPlayer = body_moving[randi() % body_moving.size()]
	aud.pitch_scale = 0.8 + ((randf() - 0.5) / 2)
	aud.play()


func play_body_turn(turn_to: float = signf(randf() - 0.5)):
	# TODO: Edit the pitch of sounds before-hand
	
	if turn_to > 0.0:
		body_turn_1.pitch_scale = 1.0 + ((randf() - 0.5) / 8.0)
		body_turn_1.play()
	else:
		body_turn_2.pitch_scale = 0.9 + ((randf() - 0.5) / 8.0)
		body_turn_2.play()
		
	if randf() < 0.75:
		var aud: AudioStreamPlayer = body_turn_click[randi() % body_turn_click.size()]
		aud.pitch_scale = 0.8 + ((randf() - 0.5) / 2)
		aud.play()
		

func play_body_move_hit() -> void:
	if GameMgr.current_bodies.size() < 2:
		body_move_hit_1.play()
	else:
		body_move_hit_2.play()


func play_body_turn_hit() -> void:
	if GameMgr.current_bodies.size() < 2:
		body_turn_hit_1.play()
	else:
		body_turn_hit_2.play()
