extends RefCounted
class_name LogicTestCase

const Log = preload("res://scripts/utils/log_helper.gd")

var _results := []

func get_name() -> String:
	return self.get_class()

func run_case() -> void:
	push_result(false, "run_case() not implemented")

func run() -> Array:
	_results.clear()
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
	if not passed:
		Log.warn("LogicTest assert failed: %s" % message)
	push_result_dict(detail)

func assert_true(condition: bool, message: String) -> void:
	push_result(condition, message)

func push_result(passed: bool, message: String, extra := {}) -> void:
	var payload := {
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
