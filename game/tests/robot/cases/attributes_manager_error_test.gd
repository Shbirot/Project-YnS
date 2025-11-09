extends "res://tests/robot/logic_test_case.gd"

const AttributesManager = preload("res://scripts/core/attributes_manager.gd")

func get_name() -> String:
	return "AttributesManagerError"

func run_case() -> void:
	var manager = AttributesManager.new()

	# Test HP error paths
	# Negative damage should be handled (no effect)
	manager.set_max_hp(100)
	manager.set_current_hp(100)
	var result = manager.apply_damage(-10)
	assert_equal(result, 100, "Negative damage has no effect")
	assert_equal(manager.get_current_hp(), 100, "HP unchanged by negative damage")

	# Negative heal should be handled (no effect)
	manager.apply_damage(30)  # HP = 70
	result = manager.heal(-20)
	assert_equal(result, 70, "Negative heal has no effect")
	assert_equal(manager.get_current_hp(), 70, "HP unchanged by negative heal")

	# Over-damage should floor at 0
	result = manager.apply_damage(200)
	assert_equal(result, 0, "Damage floors HP at 0")
	assert_equal(manager.get_current_hp(), 0, "HP cannot go below 0")

	# Heal from 0 should work
	result = manager.heal(50)
	assert_equal(result, 50, "Can heal from 0 HP")

	# General attribute error paths
	manager.reset({})
	var value = manager.get_attribute("nonexistent", 42)
	assert_equal(value, 42, "Missing attributes return provided default value")
	manager.modify_attribute("nonexistent", 5)
	assert_equal(manager.get_attribute("nonexistent", 0), 5.0, "Modifying missing attribute seeds it with delta")

	log_summary("AttributesManager handles HP error paths (negative damage/heal, over-damage, heal from death) and general attribute defaults correctly.")
