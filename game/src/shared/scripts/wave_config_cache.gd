extends RefCounted
class_name WaveConfigCache

## Wave config cache - prevents repeated parsing of wave configs
## Caches parsed wave configurations in memory

const ConfigLoader = preload("res://src/shared/scripts/config_loader.gd")

static var _cache: Dictionary = {}

static func get_wave_config(path: String) -> Dictionary:
	if _cache.has(path):
		if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
			DebugUtils.debug_log("Wave cache hit", {"path": path})
		return _cache[path]

	# Load and cache
	var config = ConfigLoader.load_wave_config(path)
	if config.size() > 0:
		_cache[path] = config
		if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
			DebugUtils.debug_log("Wave config cached", {"path": path, "waves": config.get("waves", []).size()})

	return config

static func clear_cache() -> void:
	_cache.clear()

static func has_cached(path: String) -> bool:
	return _cache.has(path)

static func get_cache_size() -> int:
	return _cache.size()
