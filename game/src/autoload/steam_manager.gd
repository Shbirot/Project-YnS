extends Node

const SteamConfig = preload("res://src/shared/resources/steam_config.gd")
const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var config_path = "res://config/steam_config.tres"

var _config: SteamConfig

func _ready() -> void:
	_load_config()
	if _config and _config.enabled:
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.warn("Steam integration not implemented yet", {"app_id": _config.app_id})

func _load_config() -> void:
	if FileAccess.file_exists(config_path):
		var data = load(config_path)
		if data is SteamConfig:
			_config = data
