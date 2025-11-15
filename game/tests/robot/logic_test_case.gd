extends RefCounted
class_name LogicTestCase

var _results = []
var _summary_lines = []

func get_name() -> String:
	return self.get_class()

func run_case() -> void:
	push_result(false, "run_case() not implemented")

func requires_ui() -> bool:
	return false

func run() -> Array:
	_results.clear()
	_summary_lines.clear()
	run_case()
	return _results.duplicate(true)

func assert_equal(actual, expected, message: String) -> void:
	var passed = actual == expected
	var detail = {
		"case": message,
		"passed": passed,
		"actual": actual,
		"expected": expected,
	}
	push_result_dict(detail)

func assert_eq(actual, expected, message: String) -> void:
	assert_equal(actual, expected, message)

func assert_true(condition: bool, message: String) -> void:
	push_result(condition, message)

func assert_false(condition: bool, message: String) -> void:
	push_result(not condition, message)

func assert_vector_almost_equal(actual: Vector2, expected: Vector2, tolerance: float, message: String) -> void:
	var passed = actual.distance_to(expected) <= tolerance
	push_result(passed, message, {
		"actual": actual,
		"expected": expected,
		"tolerance": tolerance,
	})

func push_result(passed: bool, message: String, extra = {}) -> void:
	var payload = {
		"case": message,
		"passed": passed,
	}
	for key in extra.keys():
		payload[key] = extra[key]
	push_result_dict(payload)

func push_result_dict(entry: Dictionary) -> void:
	_results.append(entry)

func get_tree_ref() -> SceneTree:
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		return loop
	return null

func log_summary(message: String) -> void:
	_summary_lines.append(message + "\n")

func get_summary_lines() -> Array:
	return _summary_lines.duplicate(true)
