extends "res://tests/robot/logic_test_case.gd"

const InputDriver = preload("res://tests/sim/input_driver.gd")

func get_name() -> String:
	return "InputDriverTest"

func run_case() -> void:
	var driver = InputDriver.new()
	driver.load_script("res://tests/sim/autoplay/autoplay_input_basic.json")
	assert_true(driver.events.size() > 0, "Script events loaded")
	driver._process(0.2)
	assert_true(Input.is_action_pressed("ui_right"), "ui_right pressed after first event")
	driver._process(2.0)
	assert_false(Input.is_action_pressed("ui_right"), "ui_right released after duration")
