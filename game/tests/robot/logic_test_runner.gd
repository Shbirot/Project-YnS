extends SceneTree

const TEST_DIRS = [
	"res://tests/robot/cases",
	"res://tests/unit",
]
const BASE_TEST = preload("res://tests/robot/logic_test_case.gd")
const AUTOLOAD_SPECS = [
	{"name": "GameConfig", "path": "res://autoload/game_config.gd"},
	{"name": "EventBus", "path": "res://autoload/event_bus.gd"},
	{"name": "GameCatalog", "path": "res://src/autoload/game_catalog.gd"},
	{"name": "LevelManager", "path": "res://autoload/level_manager.gd"},
	{"name": "DamageSystem", "path": "res://autoload/damage_system.gd"},
	{"name": "ProjectilePool", "path": "res://autoload/projectile_pool.gd"},
	{"name": "WeaponSystem", "path": "res://src/autoload/weapon_system.gd"},
	{"name": "EnemyPool", "path": "res://src/autoload/enemy_pool.gd"},
	{"name": "Logger", "path": "res://src/autoload/logger.gd"},
]

var _results = []
var _summary = {"total": 0, "failed": 0}
var _output_path = "user://logic_results.json"
var _skip_ui = OS.has_environment("SKIP_UI_TESTS")
var _case_filters : Array = []
var _matched_cases = {}
var _verbose = OS.has_environment("LOGIC_TEST_VERBOSE")

func _initialize() -> void:
	_install_autoloads()
	_disable_file_logging()
	_parse_args()
	_run_all_cases()
	_write_results()
	var exit_code = 1 if _summary.failed > 0 else 0
	quit(exit_code)

func _disable_file_logging() -> void:
	pass

func _parse_args() -> void:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--result-file="):
			_output_path = arg.split("=", true, 1)[1]
		elif arg.begins_with("--case="):
			var filter = arg.split("=", true, 1)[1]
			if filter != "":
				_case_filters.append(filter)

func _run_all_cases() -> void:
	for test_dir in TEST_DIRS:
		_run_cases_in_dir(test_dir)
	_validate_case_filters()

func _run_cases_in_dir(test_dir: String) -> void:
	var dir = DirAccess.open(test_dir)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if dir.current_is_dir() or not file.ends_with(".gd"):
			continue
		var path = test_dir + "/" + file
		if not _should_run_case(path):
			continue
		_run_case(path)
	dir.list_dir_end()

func _run_case(path: String) -> void:
	print("--- [Runner] Attempting to run case: %s" % path)
	var script = load(path)
	if script == null:
		print("--- [Runner] FAILED to load script for case: %s" % path)
		_results.append({"case": path, "passed": false, "message": "Failed to load case"})
		_summary.total += 1
		_summary.failed += 1
		return
	
	print("--- [Runner] Script loaded, instantiating case: %s" % path)
	var instance = script.new()
	if not instance is BASE_TEST:
		print("--- [Runner] FAILED, script does not extend LogicTestCase: %s" % path)
		_results.append({"case": path, "passed": false, "message": "Case does not extend LogicTestCase"})
		_summary.total += 1
		_summary.failed += 1
		return
	
	_mark_case_ran(path)
	if _skip_ui and instance.requires_ui():
		_results.append({"case": path, "passed": true, "skipped": true, "case_file": path, "message": "Skipped due to UI requirements"})
		return

	print("--- [Runner] Executing run() for case: %s" % path)
	var case_results = instance.run()
	print("--- [Runner] Finished run() for case: %s" % path)
	var summary_lines = instance.get_summary_lines()
	
	print("--- [Runner] Processing results for case: %s" % path)
	for entry in case_results:
		_summary.total += 1
		if not entry.get("passed", false):
			_summary.failed += 1
		entry["case_file"] = path
		_results.append(entry)
	
	if summary_lines.size() > 0:
		var summary_text = "; ".join(summary_lines)
		var summary_entry = {
			"case": "%s summary" % instance.get_name(),
			"case_file": path,
			"summary": summary_text,
			"passed": true,
			"summary_only": true,
		}
		_results.append(summary_entry)
		if _verbose:
			print("[LogicTestRunner] %s -> %s" % [instance.get_name(), summary_text])
	print("--- [Runner] Finished processing case: %s" % path)

func _write_results() -> void:
	var payload = {
		"success": _summary.failed == 0,
		"summary": _summary,
		"tests": _results,
	}
	var json = JSON.new()
	var text = json.stringify(payload)
	var file = FileAccess.open(_output_path, FileAccess.WRITE)
	if file:
		file.store_string(text)
	else:
		push_warning("Unable to write logic test results to %s" % _output_path)

func _install_autoloads() -> void:
	var root = get_root()
	if root == null:
		push_warning("LogicTestRunner: no root viewport available")
		return
	for spec in AUTOLOAD_SPECS:
		if root.get_node_or_null(spec.name):
			continue
		var script = load(spec.path)
		if script == null:
			push_warning("LogicTestRunner: missing autoload script %s" % spec.path)
			continue
		var node = script.new()
		if node == null:
			push_warning("LogicTestRunner: unable to instantiate %s" % spec.path)
			continue
		node.name = spec.name
		root.add_child(node)
	for spec in AUTOLOAD_SPECS:
		if not spec.get("initialize", false):
			continue
		var instance = root.get_node_or_null(spec.name)
		if instance and instance.has_method("initialize"):
			instance.initialize()

func _should_run_case(path: String) -> bool:
	if _case_filters.is_empty():
		return true
	return _case_filters.has(path)

func _mark_case_ran(path: String) -> void:
	if _case_filters.is_empty():
		return
	_matched_cases[path] = true

func _validate_case_filters() -> void:
	if _case_filters.is_empty():
		return
	for filter in _case_filters:
		if not _matched_cases.get(filter, false):
			_results.append({"case": filter, "passed": false, "message": "Specified case not found"})
			_summary.total += 1
			_summary.failed += 1
