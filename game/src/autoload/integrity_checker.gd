extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var manifest_path = "res://config/manifest.json"

func _ready() -> void:
	var cfg = SingletonUtil.get_game_config()
	var should_verify = true
	if cfg:
		should_verify = int(cfg.get_env_value("NF_VERIFY_CONFIGS", 1)) != 0
	if should_verify:
		verify_configs()

func verify_configs() -> void:
	var manifest = _load_manifest()
	if manifest.is_empty():
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.warn("Integrity manifest missing", {"path": manifest_path})
		return
	for path in manifest.keys():
		var expected = str(manifest[path].get("sha256", ""))
		var actual = _hash_file(path)
		if actual == "":
			var logger = SingletonUtil.get_logger()
			if logger:
				logger.error("Config missing for integrity check", {"path": path})
			continue
		if expected != actual:
			var logger = SingletonUtil.get_logger()
			if logger:
				logger.error("Checksum mismatch", {"path": path, "expected": expected, "actual": actual})
		else:
			var logger = SingletonUtil.get_logger()
			if logger and logger.is_enabled_for(logger.Level.DEBUG):
				logger.debug("Config checksum OK", {"path": path})

func _load_manifest() -> Dictionary:
	if not FileAccess.file_exists(manifest_path):
		return {}
	var file = FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	return data if typeof(data) == TYPE_DICTIONARY else {}

func _hash_file(path: String) -> String:
	var handle = FileAccess.open(path, FileAccess.READ)
	if handle == null:
		return ""
	var buffer = handle.get_buffer(handle.get_length())
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(buffer)
	var digest = ctx.finish()
	return digest.hex_encode()
