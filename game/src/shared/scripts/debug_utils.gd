extends Node
class_name DebugUtils

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
static var _last_log_times = {}
const DEFAULT_COOLDOWN_MS = 5000

static func debug_log(msg: String, ctx = {}) -> void:
	if _debug_disabled():
		return
	if _is_rate_limited(msg):
		return
	var logger = SingletonUtil.get_logger()
	if logger and logger.is_enabled_for(logger.Level.DEBUG):
		logger.debug(msg, ctx)

static func _debug_disabled() -> bool:
	if OS.is_debug_build():
		return false
	var value = "0"
	if OS.has_environment("DEBUG"):
		value = OS.get_environment("DEBUG")
	return value not in ["1", "true", "TRUE", "True"]

static func _is_rate_limited(msg: String) -> bool:
	var cooldown = _cooldown_ms()
	var now = Time.get_ticks_msec()
	var last = _last_log_times.get(msg, -cooldown)
	if now - last < cooldown:
		return true
	_last_log_times[msg] = now
	return false

static func _cooldown_ms() -> int:
	if OS.has_environment("DEBUG_COOLDOWN_MS"):
		return int(OS.get_environment("DEBUG_COOLDOWN_MS"))
	return DEFAULT_COOLDOWN_MS
