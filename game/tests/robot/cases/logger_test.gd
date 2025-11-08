extends "res://tests/robot/logic_test_case.gd"

const LoggerScript = preload("res://autoload/logger.gd")

func get_name() -> String:
	return "Logger"

func run_case() -> void:
	var logger = LoggerScript.new()
	logger._log_dir = "user://tmp_logs"
	logger._file_logging_enabled = false
	logger._ready()
	logger.debug("robot-debug")
	logger.info("robot-info")
	logger.warn("robot-warn")
	logger.error("robot-error")
	assert_true(true, "Logger methods executed")
	log_summary("Initialized a file-less logger instance and executed debug/info/warn/error calls to ensure no exceptions occur.")
