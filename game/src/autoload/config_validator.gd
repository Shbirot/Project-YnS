extends Node

## ConfigValidator - Validates and checksums all config files at boot
## Prevents runtime stalls from lazy config loading

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const WaveConfigCache = preload("res://src/shared/scripts/wave_config_cache.gd")

var _validated_configs: Dictionary = {}
var _checksums: Dictionary = {}

func _ready() -> void:
	_validate_all_configs()

func _validate_all_configs() -> void:
	var logger = SingletonUtil.get_logger()
	var validation_start = Time.get_ticks_msec()

	# Validate wave configs
	var wave_configs = [
		"res://config/data/waves.json",
	]

	for config_path in wave_configs:
		if not FileAccess.file_exists(config_path):
			if logger:
				logger.warn("Config file missing", {"path": config_path})
			continue

		var config = WaveConfigCache.get_wave_config(config_path)
		if config.size() == 0:
			if logger:
				logger.error("Config validation failed", {"path": config_path})
			continue

		_validated_configs[config_path] = config
		_checksums[config_path] = _compute_checksum(config)

	var validation_time = Time.get_ticks_msec() - validation_start

	if logger:
		logger.info("Config validation complete", {
			"count": _validated_configs.size(),
			"time_ms": validation_time,
			"checksums": _checksums.size()
		})

func get_validated_config(path: String) -> Dictionary:
	return _validated_configs.get(path, {})

func has_validated(path: String) -> bool:
	return _validated_configs.has(path)

func get_checksum(path: String) -> String:
	return _checksums.get(path, "")

func _compute_checksum(config: Dictionary) -> String:
	# Simple checksum: hash the JSON string
	var json_str = JSON.stringify(config)
	return str(json_str.hash())
