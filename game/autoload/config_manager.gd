extends Node

const Log = preload("res://scripts/utils/log_helper.gd")

## Loads JSON configs from config/settings/ and provides dot-access lookup.

var _settings := {}
var _env := "dev"
var _settings_dir := "res://config/settings"

func _ready() -> void:
	if OS.has_environment("NIGHTFALL_ENV"):
		_env = OS.get_environment("NIGHTFALL_ENV")
	_load_settings()
	Log.info("ConfigManager initialized for env=%s" % _env)

func _load_settings() -> void:
	_settings = {}
	var default_path = "%s/defaults.json" % _settings_dir
	_settings = _merge_dicts(_settings, _load_json(default_path))
	var env_path = "%s/%s.json" % [_settings_dir, _env]
	_settings = _merge_dicts(_settings, _load_json(env_path))

func _load_json(path: String) -> Dictionary:
	if not ResourceLoader.exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var text = file.get_as_text()
	var data = JSON.parse_string(text)
	return data if typeof(data) == TYPE_DICTIONARY else {}

func _merge_dicts(base: Dictionary, extra: Dictionary) -> Dictionary:
	var result := base.duplicate(true)
	for key in extra.keys():
		result[key] = extra[key]
	return result

func get_value(path: String, default_value = null):
	var parts = path.split(".")
	var current = _settings
	for part in parts:
		if current is Dictionary and current.has(part):
			current = current[part]
		else:
			return default_value
	return current
