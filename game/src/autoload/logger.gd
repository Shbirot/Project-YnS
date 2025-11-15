extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

enum Level { DEBUG, INFO, WARN, ERROR }

var min_level: Level = Level.INFO
var _test_listener: Callable

func _ready() -> void:
	_update_min_level()

func _update_min_level() -> void:
	var cfg = SingletonUtil.get_game_config()
	var env_text = "INFO"
	if cfg:
		env_text = str(cfg.get_env_value("NF_LOG_LEVEL", env_text))
	min_level = _parse_level(env_text)

func _parse_level(text: String) -> Level:
	match text.to_upper():
		"DEBUG":
			return Level.DEBUG
		"INFO":
			return Level.INFO
		"WARN", "WARNING":
			return Level.WARN
		"ERROR":
			return Level.ERROR
		_:
			return Level.INFO

func is_enabled_for(level: Level) -> bool:
	return level >= min_level

func debug(msg: String, ctx = {}) -> void:
	_log(Level.DEBUG, msg, ctx)

func info(msg: String, ctx = {}) -> void:
	_log(Level.INFO, msg, ctx)

func warn(msg: String, ctx = {}) -> void:
	_log(Level.WARN, msg, ctx)

func error(msg: String, ctx = {}) -> void:
	_log(Level.ERROR, msg, ctx)

func _log(level: Level, msg: String, ctx = {}) -> void:
	if not is_enabled_for(level):
		return
	var level_text = ["DEBUG", "INFO", "WARN", "ERROR"][int(level)]
	var ctx_part = ""
	if ctx is Dictionary and not ctx.is_empty():
		ctx_part = " | " + JSON.stringify(ctx)
	print("[%s] %s%s" % [level_text, msg, ctx_part])
	if _test_listener and _test_listener.is_valid():
		_test_listener.call({"level": level_text, "message": msg, "context": ctx.duplicate()})

func set_test_listener(listener: Callable) -> void:
	_test_listener = listener

func clear_test_listener() -> void:
	_test_listener = Callable()
