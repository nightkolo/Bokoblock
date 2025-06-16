## Audio system
##
## Under construction
extends Node

#var music_menu: AudioStreamPlayer ## @experimental
@onready var music_stage: AudioStreamPlayer = $Music/StageMusic

@onready var game_start: AudioStreamPlayer = $UI/GameStart
@onready var game_paused: AudioStreamPlayer = $UI/GamePaused
@onready var game_reset_01: AudioStreamPlayer = $UI/GameReset01
@onready var game_reset_02: AudioStreamPlayer = $UI/GameReset02
@onready var stage_next: AudioStreamPlayer = $UI/StageNext
@onready var stage_win: AudioStreamPlayer = $UI/StageWin

@onready var blackpoint_consumed: AudioStreamPlayer = $SFX/BlackpointConsumed

@onready var body_turn_1: AudioStreamPlayer = $SFX/BlockTurn1
@onready var body_turn_2: AudioStreamPlayer = $SFX/BlockTurn2

@onready var body_turn_hit_1: AudioStreamPlayer = $SFX/BlockTurnHit
@onready var body_turn_hit_2: AudioStreamPlayer = $SFX/BlockTurnHit2
@onready var body_move_hit_1: AudioStreamPlayer = $SFX/BlockMoveHit
@onready var body_move_hit_2: AudioStreamPlayer = $SFX/BlockMoveHit2

@onready var one_color_wall_exit: AudioStreamPlayer = $SFX/OneColorWallExit
@onready var one_color_wall_enter: AudioStreamPlayer = $SFX/OneColorWallEnter
@onready var one_color_wall_hit: AudioStreamPlayer = $SFX/OneColorWallHit

@onready var checkerboard_complete: AudioStreamPlayer = $UI/CheckerboardComplete

@onready var ui_button_click: AudioStreamPlayer = $UI/UiButtonClick
@onready var ui_button_hover: AudioStreamPlayer = $UI/UiButtonHover

var body_moving: Array[Node]
var body_turn_click: Array[Node]

var original_music_db: float
var _reset_sound: bool = true

var _tween_aud: Tween

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	original_music_db = music_stage.volume_db
	body_moving = $SFX/BodyMoving.get_children()
	body_turn_click = $SFX/BodyTurnClick.get_children()
	
	GameMgr.menu_entered.connect(func(entered: GameMgr.Menus):
		match entered:
			
			GameMgr.Menus.PAUSE, GameMgr.Menus.RUNTIME, GameMgr.Menus.CHECKERBOARD_COMPLETE:
				# TODO: Possible issue when flipping menus fast, could be fixed with transitions
				
				if !music_stage.playing:
					music_stage.volume_db = -80.0
					
					music_stage.play()
					
					if _tween_aud:
						_tween_aud.kill()
						
					_tween_aud = create_tween()
					_tween_aud.tween_property(music_stage, "volume_db", original_music_db, 1.5)
			
			_:
				if music_stage.playing:
					if _tween_aud:
						_tween_aud.kill()
						
					_tween_aud = create_tween()
					_tween_aud.tween_property(music_stage, "volume_db", -80.0, 0.75)
					
					await _tween_aud.finished

					music_stage.stop()
	)
		
	GameMgr.game_just_ended.connect(func():
		stage_win.play()
		)
		
	GameMgr.game_end.connect(func():
		if !GameMgr.has_resetted_during_board_win:
			stage_next.play()
		)
	
	GameLogic.body_hit_move.connect(play_body_move_hit)
	GameLogic.body_hit_turn.connect(play_body_turn_hit)
	
	PlayerInput.input_move.connect(func(_move_to: Vector2):
		play_body_move()
		)
	PlayerInput.input_turn.connect(play_body_turn)


func lower_higher_music(dur: float = 1.0, low: float = 15.0) -> void:
	var tween = create_tween()
	
	tween.tween_property(Audio.music_stage, "volume_db", Audio.original_music_db-low, dur)
	tween.tween_property(Audio.music_stage, "volume_db", Audio.original_music_db, dur).set_delay(dur)


func set_music(vol: float = original_music_db) -> void:
	music_stage.volume_db = vol


func play_reset_sound() -> void:
	_reset_sound = !_reset_sound
	
	if _reset_sound:
		game_reset_01.play()
	else:
		game_reset_02.play()


func play_body_move() -> void:
	if GameMgr.current_menu:
		if !GameMgr.current_menu.onscreen.is_on_screen(): # For main menu easter egg
			return
	
	var aud: AudioStreamPlayer = body_moving[randi() % body_moving.size()]
	aud.pitch_scale = 0.8 + ((randf() - 0.5) / 2)
	aud.play()


func play_body_turn(turn_to: float = signf(randf() - 0.5)):
	if GameMgr.current_menu:
		if GameMgr.current_menu.onscreen.is_on_screen(): # For main menu easter egg
			return
	
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
	if GameLogic.current_bodies.size() < 2:
		body_move_hit_1.play()
	else:
		body_move_hit_2.play()


func play_body_turn_hit() -> void:
	if GameLogic.current_bodies.size() < 2:
		body_turn_hit_1.play()
	else:
		body_turn_hit_2.play()
