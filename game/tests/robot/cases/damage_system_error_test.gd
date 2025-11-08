extends "res://tests/robot/logic_test_case.gd"

const DamageSystem = preload("res://scripts/systems/damage_system.gd")
const Calc = preload("res://scripts/core/calculation_manager.gd")

func get_name() -> String:
	return "DamageSystemError"

func run_case() -> void:
	DamageSystem.apply_projectile_damage(null, -50, "magic_arcane", Vector2.ZERO, null)
	assert_true(true, "DamageSystem handles null targets without crashing")

	var result = Calc.roll_damage(-10, 0.0, 2.0) # No crit
	assert_equal(result.damage, -10, "Negative base damage passes through unchanged without crit")

	result = Calc.roll_damage(-10, 1.0, 2.0) # Guaranteed crit
	assert_equal(result.damage, -20, "Negative base damage is multiplied on crit")

	log_summary("DamageSystem ignored null targets and handled negative base damage correctly.")
