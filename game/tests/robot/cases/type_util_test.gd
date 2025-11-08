extends "res://tests/robot/logic_test_case.gd"

const TypeUtil = preload("res://scripts/utils/type_util.gd")

func get_name() -> String:
	return "TypeUtil"

func run_case() -> void:
	test_coerce_value()
	log_summary("TypeUtil correctly coerces values from arrays to Godot types.")

func test_coerce_value():
	assert_equal(TypeUtil.coerce_value([1, 2]), Vector2(1, 2), "Array to Vector2")
	assert_equal(TypeUtil.coerce_value([1.5, 2.5]), Vector2(1.5, 2.5), "Float array to Vector2")
	assert_equal(TypeUtil.coerce_value([1, 2, 3]), Vector3(1, 2, 3), "Array to Vector3")
	assert_equal(TypeUtil.coerce_value([0.1, 0.2, 0.3, 0.4]), Color(0.1, 0.2, 0.3, 0.4), "Array to Color")
	assert_equal(TypeUtil.coerce_value("hello"), "hello", "String is unchanged")
	assert_equal(TypeUtil.coerce_value(123), 123, "Int is unchanged")
	var arr = [1, 2, "a"]
	assert_equal(TypeUtil.coerce_value(arr), arr, "Mixed array is unchanged")
