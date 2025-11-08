extends SceneTree

const TEST_DIR := "res://tests/robot/cases"
const BASE_TEST := preload("res://tests/robot/logic_test_case.gd")

var _results := []
var _summary := {"total": 0, "failed": 0}
var _output_path := "user://logic_results.json"

func _initialize() -> void:
	_parse_args()
	_setup_environment()
	_run_all_cases()
	_write_results()
	var exit_code = _summary.failed == 0 ? 0 : 1
	quit(exit_code)

func _parse_args() -> void:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--result-file="):
			_output_path = arg.split("=", true, 1)[1]

func _setup_environment() -> void:
	var controller = Engine.get_main_loop().root.get_node_or_null("GameController")
	if controller:
		controller.initialize()

func _run_all_cases() -> void:
	var dir = DirAccess.open(TEST_DIR)
	if dir == null:
		push_error("Logic tests directory missing: %s" % TEST_DIR)
		return
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if dir.current_is_dir() or not file.ends_with(".gd"):
			continue
		_run_case(TEST_DIR + "/" + file)
	dir.list_dir_end()

func _run_case(path: String) -> void:
	var script = load(path)
	if script == null:
		_results.append({"case": path, "passed": false, "message": "Failed to load case"})
		_summary.total += 1
		_summary.failed += 1
		return
	var instance = script.new()
	if not instance is BASE_TEST:
		_results.append({"case": path, "passed": false, "message": "Case does not extend LogicTestCase"})
		_summary.total += 1
		_summary.failed += 1
		return
	var case_results = instance.run()
	for entry in case_results:
		_summary.total += 1
		if not entry.get("passed", false):
			_summary.failed += 1
		entry["case_file"] = path
		_results.append(entry)

func _write_results() -> void:
	var payload = {
		"success": _summary.failed == 0,
		"summary": _summary,
		"tests": _results,
	}
	var file = FileAccess.open(_output_path, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(payload))
	else:
		push_warning("Unable to write logic test results to %s" % _output_path)
