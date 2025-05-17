## Audio system
##
## Under construction
extends Node

@onready var bus_GameSound: int = AudioServer.get_bus_index("GameSound")

var music_menu: AudioStreamPlayer ## @experimental
@onready var music_stage: AudioStreamPlayer = $Music/StageMusic

@onready var game_paused: AudioStreamPlayer = $UI/GamePaused
@onready var game_reset_01: AudioStreamPlayer = $UI/GameReset01
@onready var game_reset_02: AudioStreamPlayer = $UI/GameReset02
@onready var game_start: AudioStreamPlayer = $UI/GameStart
@onready var menu_exit: AudioStreamPlayer = $UI/MenuExit
@onready var stage_next: AudioStreamPlayer = $UI/StageNext
@onready var stage_undo_01: AudioStreamPlayer = $UI/StageUndo01
@onready var stage_win: AudioStreamPlayer = $UI/StageWin
@onready var stage_complete_jingles: Node = $UI/StageCompleteJingles
@onready var menu_enter_jingles: Node = $UI/MenuEnterJingles
@onready var block_moving_sfx: Node = $SFX/StarpointWrong/BlockMoving


@onready var block_turn_1: AudioStreamPlayer = $SFX/BlockTurn1
@onready var block_turn_2: AudioStreamPlayer = $SFX/BlockTurn2
@onready var block_turning_sound: AudioStreamPlayer = $SFX/BlockTurningSound

@onready var turn_hit: AudioStreamPlayer = $SFX/BlockTurnHit
@onready var move_hit: AudioStreamPlayer = $SFX/BlockMoveHit

@onready var starpoint_wrong: AudioStreamPlayer = $SFX/StarpointWrong
@onready var starpoint_exit: AudioStreamPlayer = $SFX/StarpointExit
@onready var starpoint_enter_1: AudioStreamPlayer = $SFX/StarpointEnter1

@onready var body_happy_01: AudioStreamPlayer = $SFX/BodyHappy01
@onready var body_happy_02: AudioStreamPlayer = $SFX/BodyHappy02

var block_moving: Array[Node]
var _stage_complete_jingles: Array[Node]

@warning_ignore("unused_private_class_variable")
var _menu_enter_jingles: Array[Node]
var _reset_sound: bool = true



func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	_stage_complete_jingles = menu_enter_jingles.get_children()
	block_moving = block_moving_sfx.get_children()
	
	GameMgr.game_entered.connect(func(entered: bool):
		AudioServer.set_bus_mute(bus_GameSound, !entered)
		
		if entered:
			if !music_stage.playing:
				music_stage.play()
		else:
			music_stage.stop()
	)
		
	# TODO: Maybe should not make everything global
	GameMgr.game_reset.connect(func():
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
		#var aud := _stage_complete_jingles[randi() % _stage_complete_jingles.size()]
		stage_next.play()
		)
	
	#GameLogic.bodies_moved.connect(func(_transformed):
		#_prev_star_happy = []
		#
		#for star: Starpoint in GameMgr.current_starpoints:
			#_prev_star_happy.push_front(star.check_satisfaction(false))
		#)
	GameLogic.state_checked.connect(func(_have_moved: bool):
		_check_game_state()
		)
	
	GameLogic.body_exited_starpoint.connect(play_starpoint_exited)
	GameLogic.body_hit_move.connect(play_block_move_hit)
	GameLogic.body_hit_turn.connect(play_block_turn_hit)
	
	PlayerInput.input_move.connect(func(_move_to: Vector2):
		play_block_move()
		)
	PlayerInput.input_turn.connect(play_block_turn)

	await get_tree().create_timer(0.1).timeout
	if GameMgr.current_ui_handler:
		GameMgr.current_ui_handler.game_pause_toggled.connect(func(_is_paused: bool):
			# TODO: lower music volume
			pass
			)

var _prev_star_happy: Array[bool]

func _check_game_state():
	# TODO: Issue with sound emission
	
	var happy_starpoints: int = 0
	var landed_starpoints: int = 0
	
	await get_tree().create_timer(0.05).timeout
	
	#for i in range(GameMgr.current_starpoints.size()):
		#if _prev_star_happy[i] == GameMgr.current_starpoints[i].check_satisfaction(false):
			#return
	
	for starpoint: Starpoint in GameMgr.current_starpoints:
		
		
		
		if starpoint.is_happy:
			happy_starpoints += 1
		elif starpoint.is_landed_on:
			landed_starpoints += 1
	
	
	
	if happy_starpoints > 0:
		var pitch := 0.5 + ((float(happy_starpoints) / float(GameLogic.match_amount)) * 1.5)
		play_starpoint_entered(pitch)
		
	if landed_starpoints > 0:
		starpoint_wrong.play()


func play_starpoint_entered(pitch: float = 1.0):
	starpoint_enter_1.pitch_scale = pitch
	starpoint_enter_1.play()


func play_starpoint_exited():
	starpoint_exit.play()


func play_block_move():
	var aud: AudioStreamPlayer = block_moving[randi() % block_moving.size()]
	aud.pitch_scale = 0.8 + ((randf() - 0.5) / 2)
	aud.play()


func play_block_turn(turn_to: float = signf(randf() - 0.5)):
	if turn_to > 0.0:
		block_turn_1.pitch_scale = 1.0 + ((randf() - 0.5) / 8.0)
		block_turn_1.play()
	else:
		block_turn_2.pitch_scale = 0.9 + ((randf() - 0.5) / 8.0)
		block_turn_2.play()
		
	if randf() < 0.75:
		block_turning_sound.play()
		

func play_block_move_hit():
	for aud in block_moving:
		if aud.playing:
			aud.stop()
	move_hit.play()


func play_block_turn_hit():
	if block_turn_1.playing:
		block_turn_1.stop()
	if block_turn_2.playing:
		block_turn_2.stop()
	turn_hit.pitch_scale = 1.0 + ((randf() - 0.5) / 4)
	turn_hit.play()
