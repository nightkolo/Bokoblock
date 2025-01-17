## Math utility/helper script
##
## Are ya ready to learn some [BokoMath]s?
extends Node
class_name BokoMath # MathUtil


static func rad_to_vector(rad: float) -> Vector2:
	var x: float = cos(rad)
	var y: float = sin(rad)
	return Vector2(x, y)


static func normalize_angle(angle: float) -> float:
	var value: float = fmod(angle, 360.0)
	if value < 0.0:
		value += 360.0
	return value


static func simplify_angle(angle: float) -> int:
	var ang: float = fmod(angle, 360.0)
	if ang < 0.0:
		ang += 360.0
	ang = abs(roundf(ang / 90.0))
	
	var value: int = mini(int(ang), 3) 
	return value


static func round_to_nearest_90(angle: float) -> float:
	return round(angle / 90.0) * 90.0
