extends "res://tests/robot/logic_test_case.gd"

const CalculationManager = preload("res://scripts/core/calculation_manager.gd")

func get_name() -> String:
	return "CalculationManagerGameplay"

func run_case() -> void:
	test_roll_damage()
	test_tick_cooldown()
	test_bad_roll_damage()
	log_summary("CalculationManager gameplay functions (damage, cooldowns) handle valid and edge cases.")

func test_roll_damage():
	var result = CalculationManager.roll_damage(10, 0.0, 2.0)
	assert_equal(result["damage"], 10, "Roll damage no crit")
	assert_true(not result["is_crit"], "Roll damage no crit flag")
	result = CalculationManager.roll_damage(10, 1.0, 2.0)
	assert_equal(result["damage"], 20, "Roll damage guaranteed crit")
	assert_true(result["is_crit"], "Roll damage guaranteed crit flag")

func test_tick_cooldown():
	assert_equal(CalculationManager.tick_cooldown(1.0, 0.5), 0.5, "Tick cooldown")
	assert_equal(CalculationManager.tick_cooldown(0.5, 1.0), 0.0, "Tick cooldown to zero")

func test_bad_roll_damage():
	var result = CalculationManager.roll_damage(-10, 0.0, 2.0)
	assert_equal(result["damage"], -10, "Roll damage no crit with negative base")
	assert_true(not result["is_crit"], "Roll damage no crit flag with negative base")
	result = CalculationManager.roll_damage(-10, 1.0, 2.0)
	assert_equal(result["damage"], -20, "Roll damage guaranteed crit with negative base")
	assert_true(result["is_crit"], "Roll damage guaranteed crit flag with negative base")
	result = CalculationManager.roll_damage(10, -0.5, 2.0)
	assert_equal(result["damage"], 10, "Roll damage with negative crit rate")
	assert_true(not result["is_crit"], "Roll damage flag with negative crit rate")

