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

static var stage_complete_anim_waittime: float = 1.5

const GAME_SCREEN_SIZE = Vector2(960.0,720.0)
const TILE_SIZE = 45.0 
const NUMBER_OF_BOARDS_PER_CHECKERBOARD = 10
const NUMBER_OF_BOARDS = 20
const NUMBER_OF_CHECKERBOARDS = 2
const STAGE_FILE_BEGIN = "res://world/game/levels/stage_"
const STAGE_FILE_END = ".tscn"


static func disable_buttons(btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in btns:
		if !(btn is Button):
			continue
			
		btn.disabled = disable


static func set_boko_color(is_bokocolor: BokoColor, set_strength: float = 1.0, set_alpha: float = 1.0) -> Color:
	var col: Color
	var s := set_strength
	var a := set_alpha
	
	match is_bokocolor:
		
		BokoColor.AQUA:
			col = Color(Color(1.0,0.77,1.0)*s,a) # I lied, cry about it.
			
		BokoColor.RED:
			col = Color(Color(1.0,0.5,0.5)*s,a)
		
		BokoColor.BLUE:
			col = Color(Color(0.5,0.5,1.0)*s,a)
			
		BokoColor.YELLOW:
			col = Color(Color(1.0,1.0,0.5)*s,a)
			
		BokoColor.GREEN:
			col = Color(Color.GREEN*s,a)
			
		BokoColor.PINK:
			col = Color(Color.PINK*s,a)
			
		BokoColor.GREY:
			col = Color(Color.GRAY*s,a)
			
	return col


static func check_file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)


static func reset_tween(t: Tween) -> void:
	if t:
		t.kill()
