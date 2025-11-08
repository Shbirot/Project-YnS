extends Node

## Simple file + stdout logger shared across the project.
const LEVELS = {"debug": "DEBUG", "info": "INFO", "warn": "WARN", "error": "ERROR"}

var _current_date := ""
var _file : FileAccess
var _log_dir := "user://logs"
var _file_logging_enabled := OS.get_environment("NIGHTFALL_DISABLE_FILE_LOGS") != "1"

func _ready() -> void:
	if _file_logging_enabled:
		_ensure_log_dir()
		_current_date = _current_date_string()
		_open_log()
	info("Logger initialized")

func _ensure_log_dir() -> void:
	var absolute_dir = ProjectSettings.globalize_path(_log_dir)
	var err = DirAccess.make_dir_recursive_absolute(absolute_dir)
	if err != OK:
		push_warning("Logger cannot create log dir %s (err=%d)" % [absolute_dir, err])

func _current_date_string() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d" % [datetime.year, datetime.month, datetime.day]

func _current_time_string() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	return "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]

func _open_log() -> void:
	var file_path = "%s/nightfall_%s.log" % [_log_dir, _current_date]
	var absolute_path = ProjectSettings.globalize_path(file_path)
	_file = FileAccess.open(absolute_path, FileAccess.WRITE_READ)
	if _file == null:
		push_warning("Logger cannot open log file at %s" % absolute_path)
	if _file:
		_file.seek_end()

func _ensure_log_file() -> void:
	var today = _current_date_string()
	if today != _current_date or _file == null:
		_current_date = today
		if _file:
			_file.close()
		_open_log()

func _log_message(level: String, message: String) -> void:
	var label = LEVELS.get(level.to_lower(), "INFO")
	var line = "[%s][%s] %s" % [_current_time_string(), label, message]
	print(line)
	if _file_logging_enabled:
		_ensure_log_file()
		if _file:
			_file.store_line(line)
			_file.flush()

func debug(message: String) -> void:
	_log_message("debug", message)

func info(message: String) -> void:
	_log_message("info", message)

func warn(message: String) -> void:
	_log_message("warn", message)

func error(message: String) -> void:
	_log_message("error", message)
