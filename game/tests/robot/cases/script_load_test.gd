extends "res://tests/robot/logic_test_case.gd"

const TARGET_DIRS := [
	"res://autoload",
	"res://scripts",
	"res://scenes",
	"res://resources",
]

var _loaded_count := 0

func get_name() -> String:
	return "ScriptLoad"

func run_case() -> void:
	_loaded_count = 0
	for dir_path in TARGET_DIRS:
		_validate_dir(dir_path)
	log_summary("Loaded %d resources across %d critical directories to ensure scenes/scripts import cleanly." % [_loaded_count, TARGET_DIRS.size()])

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
		var full_path = path.path_join(entry)
		if dir.current_is_dir():
			_validate_dir(full_path)
		else:
			if entry.ends_with(".gd") or entry.ends_with(".tscn") or entry.ends_with(".tres"):
				_load_resource(full_path)
	dir.list_dir_end()

func _load_resource(path: String) -> void:
	var res = load(path)
	var success = res != null
	if success:
		push_result(true, "Loaded %s" % path)
		_loaded_count += 1
	else:
		var file_exists = FileAccess.file_exists(path)
		var resource_exists = ResourceLoader.exists(path)
		push_result(false, "Loaded %s" % path, {
			"file_exists": file_exists,
			"resource_exists": resource_exists,
		})
