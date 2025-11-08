extends "res://tests/robot/logic_test_case.gd"

const CalculationManager = preload("res://scripts/core/calculation_manager.gd")

func get_name() -> String:
	return "CalculationManagerRandom"

func run_case() -> void:
	test_get_random_int()
	test_get_random_float()
	test_get_new_uuid()
	test_get_random_string()
	log_summary("CalculationManager random generation functions provide correct types and ranges.")

func test_get_random_int():
	var val = CalculationManager.get_random_int(1, 10)
	assert_true(val >= 1 and val <= 10, "Random int in range")
	val = CalculationManager.get_random_int(-10, -1)
	assert_true(val >= -10 and val <= -1, "Random int in negative range")
	val = CalculationManager.get_random_int(5, 5)
	assert_equal(val, 5, "Random int with same min and max")

func test_get_random_float():
	var val = CalculationManager.get_random_float(1.0, 10.0)
	assert_true(val >= 1.0 and val <= 10.0, "Random float in range")
	val = CalculationManager.get_random_float(-10.0, -1.0)
	assert_true(val >= -10.0 and val <= -1.0, "Random float in negative range")
	val = CalculationManager.get_random_float(5.5, 5.5)
	assert_equal(val, 5.5, "Random float with same min and max")

func test_get_new_uuid():
	var uuid1 = CalculationManager.get_new_uuid()
	var uuid2 = CalculationManager.get_new_uuid()
	assert_equal(len(uuid1), 32, "UUID length")
	assert_true(uuid1 != uuid2, "UUIDs are unique")

func test_get_random_string():
	var s = CalculationManager.get_random_string(10)
	assert_equal(len(s), 10, "Random string length")
	s = CalculationManager.get_random_string(0)
	assert_equal(len(s), 0, "Random string zero length")
	s = CalculationManager.get_random_string(1)
	assert_equal(len(s), 1, "Random string single char")
