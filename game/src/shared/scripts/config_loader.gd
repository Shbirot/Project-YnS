extends Node
class_name ConfigLoader

const ConfigSchema = preload("res://src/shared/scripts/config_schema.gd")
const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.error("Config file missing", {"path": path})
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.error("Config file not a dictionary", {"path": path})
		return {}
	return data

static func load_wave_config(path: String) -> Dictionary:
	var config = load_json(path)
	var errors = ConfigSchema.validate(config, ConfigSchema.WAVE_SCHEMA)
	if errors.size() > 0:
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.error("Wave config validation failed", {"path": path, "errors": errors})
		return {}
	if config.get("magic", "") != "NF_WAVES_V1":
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.error("Wave config magic mismatch", {"magic": config.get("magic", ""), "path": path})
			return {}
	return config

static func load_autoplay_config(path: String) -> Dictionary:
	var config = load_json(path)
	var errors = ConfigSchema.validate(config, ConfigSchema.AUTOPLAY_SCHEMA)
	if errors.size() > 0:
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.error("Autoplay config validation failed", {"path": path, "errors": errors})
		return {}
	return config
