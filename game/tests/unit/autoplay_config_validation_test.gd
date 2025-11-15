extends "res://tests/robot/logic_test_case.gd"

const ConfigLoader = preload("res://src/shared/scripts/config_loader.gd")

func get_name() -> String:
	return "AutoplayConfigValidationTest"

func run_case() -> void:
	var config = ConfigLoader.load_autoplay_config("res://tests/sim/autoplay/autoplay_basic.json")
	assert_false(config.is_empty(), "Autoplay config loads")

	var invalid_path = "user://invalid_autoplay.json"
	var file = FileAccess.open(invalid_path, FileAccess.WRITE)
	file.store_string("{\"scene\": 123}")
	file.close()
	var invalid = ConfigLoader.load_autoplay_config(invalid_path)
	assert_true(invalid.is_empty(), "Invalid autoplay config rejected")
