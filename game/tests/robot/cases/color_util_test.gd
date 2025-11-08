extends "res://tests/robot/logic_test_case.gd"

const ColorUtil = preload("res://scripts/utils/color_util.gd")

func get_name() -> String:
	return "ColorUtil"

func run_case() -> void:
	test_from_string()
	log_summary("ColorUtil correctly converts color strings to Color objects.")

func test_from_string():
	assert_equal(ColorUtil.from_string("black"), Color.BLACK, "String 'black' to Color.BLACK")
	assert_equal(ColorUtil.from_string("white"), Color.WHITE, "String 'white' to Color.WHITE")
	assert_equal(ColorUtil.from_string("red"), Color(1, 0, 0), "String 'red' to Color(1, 0, 0)")
	assert_equal(ColorUtil.from_string("green"), Color(0, 1, 0), "String 'green' to Color(0, 1, 0)")
	assert_equal(ColorUtil.from_string("blue"), Color(0, 0, 1), "String 'blue' to Color(0, 0, 1)")
	assert_equal(ColorUtil.from_string("yellow"), Color(1, 1, 0), "String 'yellow' to Color(1, 1, 0)")
	assert_equal(ColorUtil.from_string("cyan"), Color(0, 1, 1), "String 'cyan' to Color(0, 1, 1)")
	assert_equal(ColorUtil.from_string("magenta"), Color(1, 0, 1), "String 'magenta' to Color(1, 0, 1)")
	assert_equal(ColorUtil.from_string("#ff00ff"), Color(1, 0, 1), "Hex string to Color")
	assert_equal(ColorUtil.from_string(""), Color.BLACK, "Empty string to default color")
	assert_equal(ColorUtil.from_string("invalid", Color.RED), Color.RED, "Invalid string to specified default color")
