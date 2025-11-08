extends "res://tests/robot/logic_test_case.gd"

const AttributesManager = preload("res://scripts/core/attributes_manager.gd")

func get_name() -> String:
	return "AttributesManagerError"

func run_case() -> void:
	var manager = AttributesManager.new()
	manager.reset({})
	var value = manager.get_attribute("nonexistent", 42)
	assert_equal(value, 42, "Missing attributes return provided default value")
	manager.modify_attribute("nonexistent", 5)
	assert_equal(manager.get_attribute("nonexistent", 0), 5.0, "Modifying missing attribute seeds it with delta")
	log_summary("AttributesManager returned the supplied default for unknown keys and seeded new attributes when modified.")
