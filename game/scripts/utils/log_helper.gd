extends RefCounted
class_name Log

const SceneTreeUtil = preload("res://scripts/utils/scene_tree_util.gd")

static func _get_logger():
	return SceneTreeUtil.get_autoload("Logger")

static func debug(message: String) -> void:
	var logger = _get_logger()
	if logger and logger.has_method("debug"):
		logger.debug(message)
	else:
		print("[DEBUG] %s" % message)

static func info(message: String) -> void:
	var logger = _get_logger()
	if logger and logger.has_method("info"):
		logger.info(message)
	else:
		print("[INFO] %s" % message)

static func warn(message: String) -> void:
	var logger = _get_logger()
	if logger and logger.has_method("warn"):
		logger.warn(message)
	else:
		push_warning(message)

static func error(message: String) -> void:
	var logger = _get_logger()
	if logger and logger.has_method("error"):
		logger.error(message)
	else:
		push_error(message)
