
extends Control

@onready var monolog_text: MonologText = %MonologText
@onready var boko: CharacterBoko = %Boko

func _ready() -> void:
	monolog_text.next_monologue_entered.connect(func(_is_index: int):
		boko.anim_bounce()
		)
		
	monolog_text.boko_pose_set.connect(func(is_pose: GameLogic.BokoPose):
		print(is_pose)
		
		# TODO: uhhh, what the fuck is this
		match is_pose:
			
			GameLogic.BokoPose.NORMAL:
				boko.pose_normal()
				boko.anim_star_spin(30.0)
				boko.anim_star_bounce()
			
			GameLogic.BokoPose.THINKING:
				boko.pose_thinking()
				boko.anim_star_spin()
				boko.anim_star_bounce()
			
			GameLogic.BokoPose.NO_WORRY:
				boko.pose_no_worry()
				boko.anim_star_spin(30.0)
				boko.anim_star_bounce()
			
			GameLogic.BokoPose.WINK:
				boko.pose_wink()
				boko.anim_star_spin(90.0)
				boko.anim_star_bounce(0.5)
				
			GameLogic.BokoPose.HAPPY:
				boko.pose_excited()
				boko.anim_star_spin(30.0)
				boko.anim_star_bounce()
		)
