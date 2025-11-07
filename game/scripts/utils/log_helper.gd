extends RefCounted

class_name Log

static func _get_logger():
	var loop = Engine.get_main_loop()
	if loop and loop is SceneTree:
		var root = loop.current_scene
		if root and root.has_node("/root/Logger"):
			return root.get_node("/root/Logger")
	return null

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
