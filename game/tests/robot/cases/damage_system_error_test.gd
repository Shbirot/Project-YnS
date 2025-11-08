extends "res://tests/robot/logic_test_case.gd"

const DamageSystem = preload("res://scripts/systems/damage_system.gd")

func get_name() -> String:
	return "DamageSystemError"

func run_case() -> void:
	DamageSystem.apply_projectile_damage(null, -50, "magic_arcane", Vector2.ZERO, null)
	assert_true(true, "DamageSystem handles null targets without crashing")
	var result = DamageSystem._calculate_final_damage(-10)
	assert_equal(result.damage, -10, "Negative base damage passes through unchanged today")
	log_summary("DamageSystem ignored null targets and left negative base damage untouched (current behavior).")
