extends Node

@onready var music_stage: AudioStreamPlayer = $Music/StageMusic


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

	# this code is so bad lol
	
	GameMgr.game_entered.connect(func(entered: bool):
		if entered:
			if !music_stage.playing:
				music_stage.play()
		else:
			music_stage.stop()
	)
