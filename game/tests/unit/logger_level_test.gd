extends "res://tests/robot/logic_test_case.gd"

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

func get_name() -> String:
	return "LoggerLevelTest"

func run_case() -> void:
	var logger = SingletonUtil.get_logger()
	assert_true(logger != null, "Logger autoload available")
	var captured: Array = []
	var listener = Callable(self, "_capture_log").bind(captured)
	logger.set_test_listener(listener)
	var original_level = logger.min_level
	logger.min_level = logger.Level.INFO
	logger.debug("Hidden debug")
	logger.info("Visible info", {"context": 1})
	logger.clear_test_listener()
	logger.min_level = original_level

	assert_equal(captured.size(), 1, "Only info-level message captured at INFO level")
	assert_equal(captured[0]["level"], "INFO", "Captured log level is INFO")
	assert_equal(captured[0]["message"], "Visible info", "Captured message matches")

func _capture_log(entry: Dictionary, store: Array) -> void:
	store.append(entry)
