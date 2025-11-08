extends RefCounted

class_name Log

static func _get_logger():
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		var root: Node = tree.get_root()
		if root:
			return root.get_node_or_null("Logger")
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
