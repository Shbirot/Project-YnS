extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

## Lightweight runtime config loader shared across dev/stage/prod exports.

var profile : String = "dev"

func _ready() -> void:
	profile = _deduce_profile()
	var logger = SingletonUtil.get_logger() if Engine.has_singleton("SingletonUtil") else null
	if logger:
		logger.info("GameConfig ready", {"profile": profile})

var world_bounds = Rect2(Vector2(-768, -768), Vector2(1536, 1536))

func get_world_bounds() -> Rect2:
	return world_bounds

func set_world_bounds(bounds: Rect2) -> void:
	world_bounds = bounds

func get_env_value(key: String, default_value):
	if OS.has_environment(key):
		return _coerce_value(OS.get_environment(key), default_value, key)
	return default_value

func _coerce_value(raw: String, template, key: String):
	var template_type = typeof(template)
	if template_type == TYPE_INT:
		return int(raw)
	if template_type == TYPE_FLOAT:
		return float(raw)
	if template_type == TYPE_BOOL:
		var lowered = raw.to_lower()
		return lowered in ["1", "true", "yes", "on"]
	if template_type == TYPE_STRING:
		return raw
	push_warning("GameConfig: Cannot coerce env %s into type %s" % [key, template_type])
	return template

func _deduce_profile() -> String:
	if OS.has_environment("NIGHTFALL_ENV"):
		return OS.get_environment("NIGHTFALL_ENV")
	return "dev"
