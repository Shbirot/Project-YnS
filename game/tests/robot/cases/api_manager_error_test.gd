extends "res://tests/robot/logic_test_case.gd"

const ApiManager = preload("res://scripts/core/api_manager.gd")
const AttributesManager = preload("res://scripts/core/attributes_manager.gd")

func get_name() -> String:
	return "ApiManagerError"

func run_case() -> void:
	# Create isolated APIManager instance
	var api = ApiManager.new()
	var attributes_mgr = AttributesManager.new()

	# Test error path: managers not connected
	api._attributes_manager = null
	api.damage_hero(50, null)  # Should not crash
	assert_equal(api.get_hero_hp(), 0, "Returns 0 HP when AttributesManager unavailable")

	api.heal_hero(30)  # Should not crash
	assert_equal(api.get_hero_hp(), 0, "Still returns 0 after heal attempt without manager")

	# Wire up manager and verify recovery
	api._attributes_manager = attributes_mgr
	api.set_hero_max_hp(100)
	api.set_hero_hp(100)
	assert_equal(api.get_hero_hp(), 100, "HP management works after manager connected")

	# Test negative damage (should be ignored)
	api.damage_hero(-10, null)
	assert_equal(api.get_hero_hp(), 100, "Negative damage has no effect")

	# Test negative heal (should be ignored)
	api.damage_hero(30, null)  # Bring HP to 70
	api.heal_hero(-20)
	assert_equal(api.get_hero_hp(), 70, "Negative heal has no effect")

	# Test attribute access without manager
	api._attributes_manager = null
	var attr = api.get_hero_attribute("fire_rate", 0.6)
	assert_equal(attr, 0.6, "Returns default when manager unavailable")

	log_summary("APIManager handles error paths gracefully: missing managers, negative values, and returns defaults.")
