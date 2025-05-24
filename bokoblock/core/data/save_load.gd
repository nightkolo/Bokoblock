extends Node
class_name SaverLoader

signal game_saved()
signal game_loaded()

const SAVE_LOCATION = "user://savedata.json"


func save_game() -> void:
	print("saving...")
	
	var file: FileAccess = FileAccess.open(SAVE_LOCATION, FileAccess.WRITE)
	var json: String = JSON.stringify(GameData.runtime_data)
	
	file.store_line(json)
	
	game_saved.emit()
	GameMgr.game_data_saved.emit()

	file.close()
	
	print("Save successful! :D")


func load_game() -> void:
	print("loading...")
	
	if not FileAccess.file_exists(SAVE_LOCATION):
		print("Could not find %s." % SAVE_LOCATION)
		new_game()
		return

	var file: FileAccess = FileAccess.open(SAVE_LOCATION, FileAccess.READ)
	
	var saved_data = JSON.parse_string(file.get_as_text())
	
	if typeof(saved_data) != TYPE_DICTIONARY:
		push_error("Invalid save file format.")
		new_game()
		return
	
	GameData.runtime_data = (saved_data as Dictionary).duplicate(true)
	
	game_loaded.emit()
	GameMgr.game_data_loaded.emit()

	file.close()
	
	print("Load successful! :D")
	
	
func new_game() -> void:
	print("starting new game...")
	
	GameData.runtime_data = GameData.DEFAULT_GAME_DATA.duplicate(true)
	
	save_game()


## @experimental
func get_stage_data(level_id: int) -> Dictionary:
	var id: String = str(level_id)
	
	if not GameData.runtime_data.has(id):
		GameData.runtime_data[id] = {"starred": false, "best_score": 0}
		
	return GameData.runtime_data[id]
