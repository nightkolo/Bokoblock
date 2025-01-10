extends Control

@export var loop_dur_1: float = 1.7
@export var loop_dur_2: float = 1.4

@onready var chibi_boko: ChibiBoko = $CharacterChibiBoko
@onready var chibi_boko_2: ChibiBoko = $CharacterChibiBoko2
@onready var chibi_boko_3: ChibiBoko = $CharacterChibiBoko3


func _ready() -> void:
	chibi_boko_3.start_breathing()
	chibi_boko_3.start_blinking()
	
	preview_loop_anim()
	
	for l: Label in [$Label, $Label3, $Label2]:
		var tween := create_tween().set_loops()
		var amplitude := 3.0
		var dur := 1.0
		
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(l,"rotation",deg_to_rad(amplitude),dur)
		tween.tween_property(l,"rotation",deg_to_rad(-amplitude),dur)


func preview_loop_anim() -> void:
	chibi_boko.start_speaking()
	chibi_boko_2.be_happy()
	await get_tree().create_timer(loop_dur_1).timeout
	chibi_boko.stop_speaking()
	chibi_boko_2.be_neutral()
	await get_tree().create_timer(loop_dur_2).timeout
	preview_loop_anim()
