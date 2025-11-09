extends "res://tests/robot/logic_test_case.gd"

const AttributesManager = preload("res://scripts/core/attributes_manager.gd")

func get_name() -> String:
	return "AttributesManager"

func run_case() -> void:
	var manager = AttributesManager.new()

	# Test dedicated HP methods
	manager.set_max_hp(100)
	manager.set_current_hp(100)
	assert_equal(manager.get_max_hp(), 100, "Max HP set correctly")
	assert_equal(manager.get_current_hp(), 100, "Current HP set correctly")

	# Test apply_damage
	var new_hp = manager.apply_damage(30)
	assert_equal(new_hp, 70, "apply_damage returns new HP")
	assert_equal(manager.get_current_hp(), 70, "Current HP reduced by damage")

	# Test heal
	new_hp = manager.heal(20)
	assert_equal(new_hp, 90, "heal returns new HP")
	assert_equal(manager.get_current_hp(), 90, "Current HP increased by heal")

	# Test heal capping at max
	new_hp = manager.heal(50)
	assert_equal(new_hp, 100, "Heal capped at max HP")
	assert_equal(manager.get_current_hp(), 100, "HP cannot exceed max")

	# Test is_dead
	assert_false(manager.is_dead(), "Hero not dead at full HP")
	manager.apply_damage(100)
	assert_true(manager.is_dead(), "Hero dead at 0 HP")
	assert_equal(manager.get_current_hp(), 0, "HP floored at 0")

	# Test general attributes (non-HP)
	manager.reset({
		"fire_rate": 0.5,
		"projectile_speed": 600.0,
		"crit_rate": 0.1,
		"crit_multiplier": 1.4,
	})
	assert_equal(manager.get_attribute("fire_rate", 0), 0.5, "fire_rate set via reset")
	manager.modify_attribute("fire_rate", -0.1)
	assert_equal(manager.get_attribute("fire_rate", 0), 0.4, "fire_rate modification applied")
	manager.set_attribute("crit_rate", 0.25)
	assert_equal(manager.get_attribute("crit_rate", 0), 0.25, "crit rate override works")

	log_summary("AttributesManager manages dedicated HP (set/damage/heal/death), general attributes (reset/modify/set), and enforces HP bounds.")
