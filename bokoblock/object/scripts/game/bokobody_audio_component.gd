extends Node2D
class_name BokobodyAudio


@onready var bokobody: Bokobody = get_parent() as Bokobody

@onready var block_moving_01: AudioStreamPlayer2D = $BlockMoving01
@onready var block_moving_02: AudioStreamPlayer2D = $BlockMoving02
@onready var block_moving_03: AudioStreamPlayer2D = $BlockMoving03
@onready var block_moving_04: AudioStreamPlayer2D = $BlockMoving04
@onready var block_turn_01: AudioStreamPlayer2D = $BlockTurn01
@onready var block_turn_02: AudioStreamPlayer2D = $BlockTurn02
@onready var block_turn_03: AudioStreamPlayer2D = $BlockTurn03
@onready var block_turn_04: AudioStreamPlayer2D = $BlockTurn04
@onready var block_turn_05: AudioStreamPlayer2D = $BlockTurn05
@onready var block_turn_06: AudioStreamPlayer2D = $BlockTurn06
@onready var block_turn_07: AudioStreamPlayer2D = $BlockTurn07
@onready var block_moving_05: AudioStreamPlayer2D = $BlockMoving
@onready var block_turning_sound: AudioStreamPlayer2D = $BlockTurningSound


@onready var move_hit: AudioStreamPlayer2D = $MoveHit
@onready var move_hit_2: AudioStreamPlayer2D = $MoveHit2
@onready var move_hit_3: AudioStreamPlayer2D = $MoveHit3
@onready var turn_hit: AudioStreamPlayer2D = $TurnHit


func _ready() -> void:
	if !(bokobody is Bokobody):
		push_error("")
		return
		
	
		
	#bokobody.turn_stopped.connect(func():
		#if block_turn_06.playing:
			#block_turn_06.stop()
		#if block_turn_07.playing:
			#block_turn_07.stop()
		#turn_hit.pitch_scale = 1.0 + ((randf() - 0.5) / 4)
		#turn_hit.play()
		#)
		#
	#bokobody.move_stopped.connect(func():
		#if block_moving_05.playing:
			#block_moving_05.stop()
		#move_hit.play()
		#)
		
	#bokobody.has_moved.connect(func(_move_to: Vector2):
		#block_moving_05.pitch_scale = 0.8 + ((randf() - 0.5) / 2)
		#block_moving_05.play()
		#)
		#
	#bokobody.has_turned.connect(func(turn_to: float):
		#if turn_to > 0.0:
			#block_turn_06.play()
		#else:
			#block_turn_07.play()
			#
		#if randf() < 0.5:
			#print("me")
			#block_turning_sound.play()
		#)
		
