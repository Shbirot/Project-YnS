extends RefCounted
class_name TypeUtil

static func coerce_value(value):
	if value is Array:
		if value.size() == 2 and _is_numeric_array(value):
			return Vector2(value[0], value[1])
		if value.size() == 3 and _is_numeric_array(value):
			return Vector3(value[0], value[1], value[2])
		if value.size() == 4 and _is_numeric_array(value):
			return Color(value[0], value[1], value[2], value[3])
	return value

static func _is_numeric_array(arr: Array) -> bool:
	for item in arr:
		if not (typeof(item) in [TYPE_INT, TYPE_FLOAT]):
			return false
	return true
