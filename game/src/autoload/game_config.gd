extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

## Lightweight runtime config loader shared across dev/stage/prod exports.
## Caches ENV values at boot to avoid repeated OS calls

var profile : String = "dev"
var _env_cache: Dictionary = {}

func _ready() -> void:
	profile = _deduce_profile()
	_cache_all_env_values()
	var logger = SingletonUtil.get_logger() if Engine.has_singleton("SingletonUtil") else null
	if logger:
		logger.info("GameConfig ready", {"profile": profile, "cached_envs": _env_cache.size()})

var world_bounds = Rect2(Vector2(-768, -768), Vector2(1536, 1536))

func get_world_bounds() -> Rect2:
	return world_bounds

func set_world_bounds(bounds: Rect2) -> void:
	world_bounds = bounds

func get_env_value(key: String, default_value):
	# Use cached value if available
	if _env_cache.has(key):
		return _env_cache[key]

	# Fallback to OS.get_environment and cache result
	if OS.has_environment(key):
		var value = _coerce_value(OS.get_environment(key), default_value, key)
		_env_cache[key] = value
		return value
	return default_value

func _cache_all_env_values() -> void:
	# Cache common ENV variables at boot
	var common_keys = [
		"NF_DEBUG", "NF_DEBUG_INPUT", "DEBUG", "DEBUG_COOLDOWN_MS",
		"NF_HERO_MAX_SPEED", "NF_HERO_ACCELERATION", "NF_HERO_FRICTION",
		"NF_HERO_CAMERA_LERP", "NF_HERO_MAX_HEALTH",
		"NF_ENEMY_MAX_HEALTH", "NF_ENEMY_MOVE_SPEED",
		"NF_ENEMY_ACCELERATION", "NF_ENEMY_FRICTION",
		"NF_WAVE_CONFIG_PATH", "NF_SPAWN_PADDING",
		"NF_ANIM_HERO_SPEED_SCALE", "NF_ANIM_ENEMY_SPEED_SCALE"
	]

	for key in common_keys:
		if OS.has_environment(key):
			# Store raw value, will be coerced when get_env_value is called
			_env_cache[key] = OS.get_environment(key)

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
