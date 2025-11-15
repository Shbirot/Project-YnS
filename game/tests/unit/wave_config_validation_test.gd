extends "res://tests/robot/logic_test_case.gd"

const ConfigLoader = preload("res://src/shared/scripts/config_loader.gd")

func get_name() -> String:
	return "WaveConfigValidationTest"

func run_case() -> void:
	var config = ConfigLoader.load_wave_config("res://config/data/waves.json")
	assert_false(config.is_empty(), "Valid waves config loads correctly")

	var invalid_path = "user://invalid_waves.json"
	var file = FileAccess.open(invalid_path, FileAccess.WRITE)
	file.store_string("{}")
	file.close()
	var invalid = ConfigLoader.load_wave_config(invalid_path)
	assert_true(invalid.is_empty(), "Invalid wave config rejected")
