extends Node
class_name InputDriver

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

var events: Array = []
var elapsed = 0.0
var _current_index = 0
var _active = false

func load_script(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.warn("InputDriver could not read script", {"path": path})
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_ARRAY:
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.warn("InputDriver script malformed", {"path": path})
		return
	events = data.duplicate()
	events.sort_custom(Callable(self, "_sort_by_time"))
	_current_index = 0
	elapsed = 0.0
	_active = true
	set_process(true)
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("InputDriver loaded script", {"events": events.size(), "path": path})

func _process(delta: float) -> void:
	if not _active or events.is_empty():
		return
	elapsed += delta
	while _current_index < events.size() and events[_current_index].get("time", 0.0) <= elapsed:
		_fire_event(events[_current_index])
		_current_index += 1
	if _current_index >= events.size():
		_active = false

func _fire_event(entry: Dictionary) -> void:
	var action = entry.get("action", "")
	if action == "":
		return
	var pressed = entry.get("pressed", true)
	var strength = float(entry.get("strength", 1.0))
	var event = InputEventAction.new()
	event.action = action
	event.pressed = pressed
	event.strength = strength
	Input.parse_input_event(event)

func _sort_by_time(a: Dictionary, b: Dictionary) -> bool:
	return a.get("time", 0.0) < b.get("time", 0.0)
