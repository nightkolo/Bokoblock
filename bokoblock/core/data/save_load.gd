extends Node
class_name SaverLoader

signal game_saved()
signal game_loaded()

const SAVE_LOCATION = "user://savedata.json"


signal medals_saved()
signal medals_loaded()

const MEDAL_SAVE_LOCATION = "user://medaldata.json"


func save_medals() -> void:
	print("saving medals...")
	
	var file: FileAccess = FileAccess.open(MEDAL_SAVE_LOCATION, FileAccess.WRITE)
	var json: String = JSON.stringify(GameData.medal_data)
	
	file.store_line(json)
	
	medals_saved.emit()
	GameMgr.game_medals_data_saved.emit()

	file.close()
	
	print("Medal save successful! :D")


func load_medals() -> void:
	print("loading medals...")
	
	if not FileAccess.file_exists(MEDAL_SAVE_LOCATION):
		print("Could not find %s." % MEDAL_SAVE_LOCATION)
		new_game_medals()
		return

	var file: FileAccess = FileAccess.open(MEDAL_SAVE_LOCATION, FileAccess.READ)
	
	var saved_data = JSON.parse_string(file.get_as_text())
	
	if typeof(saved_data) != TYPE_DICTIONARY:
		push_error("Invalid save file format.")
		new_game_medals()
		return
	
	GameData.medal_data = (saved_data as Dictionary).duplicate(true)
	
	medals_loaded.emit()
	GameMgr.game_medals_data_loaded.emit()

	file.close()
	
	print("Medal load successful! :D")


func new_game_medals() -> void:
	print("starting new game medals...")
	
	GameData.medal_data = GameData.DEFAULT_MEDAL_DATA.duplicate(true)
	
	save_medals()


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
