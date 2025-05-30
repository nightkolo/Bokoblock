## Math utility/helper script
##
## Are ya ready to learn some [BokoMath]s?
extends Node
class_name BokoMath # MathUtil


static func rad_to_vector(rad: float) -> Vector2:
	return Vector2(cos(rad), sin(rad))


static func normalize_angle(angle: float) -> float:
	var value: float = fmod(angle, 360.0)
	if value < 0.0:
		value += 360.0
	return value


static func simplify_angle(angle: float) -> int:
	var ang: float = fmod(angle, 360.0)
	if ang < 0.0:
		ang += 360.0
	return mini(int(absf(roundf(ang / 90.0))), 3)


static func round_to_nearest_90(angle: float) -> float:
	return roundf(angle / 90.0) * 90.0


static func is_even(num: int) -> bool:
	return num % 2 == 0
