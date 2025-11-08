extends "res://tests/robot/logic_test_case.gd"

const AttributesManager = preload("res://scripts/core/attributes_manager.gd")

func get_name() -> String:
	return "AttributesManager"

func run_case() -> void:
	var manager = AttributesManager.new()
	manager.reset({
		"hp": 80.0,
		"fire_rate": 0.5,
		"projectile_speed": 600.0,
		"crit_rate": 0.1,
		"crit_multiplier": 1.4,
	})
	assert_equal(manager.get_attribute("hp", 0), 80.0, "hp set via reset")
	manager.modify_attribute("hp", 20.0)
	assert_equal(manager.get_attribute("hp", 0), 100.0, "hp modification applied")
	manager.set_attribute("crit_rate", 0.25)
	assert_equal(manager.get_attribute("crit_rate", 0), 0.25, "crit rate override works")
