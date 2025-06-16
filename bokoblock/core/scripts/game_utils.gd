## Game utility/helper script
extends Node
class_name GameUtil

enum BokoColor {
	AQUA = 0,
	RED = 1,
	BLUE = 2,
	YELLOW = 3,
	GREEN = 4,
	PINK = 5,
	GREY = 99
	}

const TILE_SIZE = 45.0 
const NUMBER_OF_BOARDS_PER_CHECKERBOARD = 10
const NUMBER_OF_BOARDS = 20
const NUMBER_OF_CHECKERBOARDS = 2
const STAGE_FILE_BEGIN = "res://world/game/levels/stage_"
const STAGE_FILE_END = ".tscn"


static func get_board_complete_anim_waittime() -> float:
	if is_board_completed():
		return 2.2
	else:
		return 1.5


static func is_board_completed() -> bool:
	if !GameData.runtime_data.has(str(GameMgr.board_id)):
		return false
		
	return GameData.runtime_data[str(GameMgr.board_id)]["completed"] == true


static func disable_buttons(btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in btns:
		if !(btn is Button):
			continue
			
		btn.disabled = disable


static func set_boko_color(is_bokocolor: BokoColor, set_strength: float = 1.0, set_alpha: float = 1.0) -> Color:
	var col: Color
	
	if GameMgr.get_colorblind_mode_setting():
		match is_bokocolor:
			
			BokoColor.AQUA:
				col = Color(Color(1.0,0.77,1.0)*set_strength,set_alpha) # I lied, cry about it.
				
			BokoColor.RED:
				col = Color(Color(1.0,0.0,0.0)*set_strength,set_alpha)
			
			BokoColor.BLUE:
				col = Color(Color(0.0,0.0,1.0)*set_strength,set_alpha)
				
			BokoColor.YELLOW:
				col = Color(Color(1.0,1.0,0.0)*set_strength,set_alpha)
				
			BokoColor.GREEN:
				col = Color(Color(0.0,0.5,0.0)*set_strength,set_alpha)
				
			BokoColor.PINK:
				col = Color(Color.PINK*set_strength,set_alpha)
				
			BokoColor.GREY:
				col = Color(Color.GRAY*set_strength,set_alpha)

	else:
		match is_bokocolor:
			
			BokoColor.AQUA:
				col = Color(Color(1.0,0.77,1.0)*set_strength,set_alpha)
				
			BokoColor.RED:
				col = Color(Color(1.0,0.5,0.5)*set_strength,set_alpha)
			
			BokoColor.BLUE:
				col = Color(Color(0.5,0.5,1.0)*set_strength,set_alpha)
				
			BokoColor.YELLOW:
				col = Color(Color(1.0,1.0,0.5)*set_strength,set_alpha)
				
			BokoColor.GREEN:
				col = Color(Color.GREEN*set_strength,set_alpha)
				
			BokoColor.PINK:
				col = Color(Color.PINK*set_strength,set_alpha)
				
			BokoColor.GREY:
				col = Color(Color.GRAY*set_strength,set_alpha)
			
	return col
	

static func reset_tween(t: Tween) -> void:
	if t:
		t.kill()
