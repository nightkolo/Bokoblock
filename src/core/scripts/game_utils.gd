## Game utility/helper script
## @experimental
extends Node
class_name GameUtil

enum BokoColor {AQUA = 0, RED = 1, BLUE = 2, YELLOW = 3, GREEN = 4, PINK = 5, GREY = 99}
enum BokoCharacterPose {NORMAL = 0, THINKING = 1, NO_WORRY = 2, HAPPY = 3, WINK = 4}
enum BackgroundEffect {SCROLL = 0, ROTATE = 1, ZOOM = 2, SKEW = 3} ## @experimental

static var stage_complete_anim_waittime: float = 2.0

const GAME_SCREEN_SIZE = Vector2(960,720)
const TILE_SIZE = 45.0 
const NUMBER_OF_STAGES = 69
const STAGE_FILE_BEGIN = "res://world/runtime/levels/stage_"
const STAGE_FILE_END = ".tscn"


static func set_boko_color(is_bokocolor: BokoColor) -> Color:
	var col: Color
	
	match is_bokocolor:
		
		BokoColor.AQUA:
			col = Color(1.0,0.77,1.0) # I lied, cry about it.
			
		BokoColor.RED:
			col = Color(Color(1.0,0.5,0.5))
		
		BokoColor.BLUE:
			col = Color(Color(0.5,0.5,1.0))
			
		BokoColor.YELLOW:
			col = Color(Color(1.0,1.0,0.5))
			
		BokoColor.GREEN:
			col = Color(Color.GREEN)
			
		BokoColor.PINK:
			col = Color(Color.PINK)
			
		BokoColor.GREY:
			col = Color(Color.GRAY)
			
	return col


static func check_file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)


static func rad_to_vector(rad: float) -> Vector2:
	var x = cos(rad)
	var y = sin(rad)
	return Vector2(x, y)
