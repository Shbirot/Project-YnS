extends "res://tests/robot/logic_test_case.gd"

const TARGET_DIRS := [
	"res://autoload",
	"res://scripts",
	"res://scenes",
	"res://resources",
]

func get_name() -> String:
	return "ScriptLoad"

func run_case() -> void:
	for dir_path in TARGET_DIRS:
		_validate_dir(dir_path)

func _validate_dir(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		push_result(false, "Missing directory %s" % path)
		return
	dir.list_dir_begin()
	while true:
		var entry = dir.get_next()
		if entry == "":
			break
		if entry.begins_with('.'):
			continue
		var full_path = path.plus_file(entry)
		if dir.current_is_dir():
			_validate_dir(full_path)
		else:
			if entry.ends_with(".gd") or entry.ends_with(".tscn") or entry.ends_with(".tres"):
				_load_resource(full_path)
	dir.list_dir_end()

func _load_resource(path: String) -> void:
	var res = load(path)
	var success = res != null
	push_result(success, "Loaded %s" % path)
