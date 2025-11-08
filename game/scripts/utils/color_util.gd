extends RefCounted

class_name ColorUtil

static func from_string(value: String, default_color: Color = Color.BLACK) -> Color:
	var trimmed = value.strip_edges().to_lower()
	if trimmed == "":
		return default_color
	match trimmed:
		"black":
			return Color.BLACK
		"white":
			return Color.WHITE
		"red":
			return Color(1, 0, 0)
		"green":
			return Color(0, 1, 0)
		"blue":
			return Color(0, 0, 1)
		"yellow":
			return Color(1, 1, 0)
		"cyan":
			return Color(0, 1, 1)
		"magenta":
			return Color(1, 0, 1)
		_:
			if trimmed.begins_with("#"):
				return Color(trimmed)
	return default_color
