extends "res://tests/robot/logic_test_case.gd"

const DamageSystem = preload("res://scripts/systems/damage_system.gd")

func get_name() -> String:
	return "DamageSystem"

func run_case() -> void:
	var result = DamageSystem._calculate_final_damage(20)
	assert_true(result.has("damage"), "result contains damage")
	assert_true(result.has("is_crit"), "result contains crit flag")
	assert_true(result.damage >= 0, "damage non-negative")
