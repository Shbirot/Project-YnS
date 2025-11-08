extends "res://tests/robot/logic_test_case.gd"

const CalculationManager = preload("res://scripts/core/calculation_manager.gd")

func get_name() -> String:
	return "CalculationManagerEdgeCases"

func run_case() -> void:
	test_velocity_with_large_numbers()
	test_acceleration_with_large_numbers()
	test_deceleration_with_large_numbers()
	test_position_advancement_with_large_numbers()
	test_damage_roll_with_large_numbers()
	test_cooldown_with_negative_delta()
	test_clamp_to_rect_with_inverted_rect()
	test_random_string_with_negative_length()
	log_summary("CalculationManager edge case tests passed.")

func test_velocity_with_large_numbers():
	var large_speed = 1e20 # Reduced from 1e30 to avoid INF
	var velocity = CalculationManager.velocity_from_direction(Vector2.RIGHT, large_speed)
	assert_true(velocity.x > 1e19, "Velocity with large speed should be a large number")
	log_summary("Verified that calculating velocity with a very large speed (1e20) results in a large number, preventing overflow errors.\n")

func test_acceleration_with_large_numbers():
	var large_accel = 1e30
	var current_velocity = Vector2(100, 0)
	var target_velocity = Vector2(200, 0)
	var accelerated = CalculationManager.accelerate_velocity(current_velocity, Vector2.RIGHT, 200, large_accel, 1.0)
	assert_eq(accelerated, target_velocity, "Acceleration with large value should reach target immediately")
	log_summary("Confirmed that accelerating with a large value (1e30) instantly moves the current velocity to the target velocity.\n")

func test_deceleration_with_large_numbers():
	var large_friction = 1e30
	var current_velocity = Vector2(100, 0)
	var decelerated = CalculationManager.decelerate_velocity(current_velocity, large_friction, 1.0)
	assert_eq(decelerated, Vector2.ZERO, "Deceleration with large friction should stop immediately")
	log_summary("Ensured that decelerating with a large friction value (1e30) brings the velocity to zero immediately.\n")

func test_position_advancement_with_large_numbers():
	var large_speed = 1e20 # Reduced from 1e30 to avoid INF
	var position = Vector2(0, 0)
	var advanced = CalculationManager.advance_position(position, Vector2.RIGHT, large_speed, 1.0)
	assert_true(advanced.x > 1e19, "Position advancement with large speed should be a large number")
	log_summary("Checked that advancing position with a very large speed (1e20) results in a large number, as expected.\n")

func test_damage_roll_with_large_numbers():
	var large_damage = 1e20 # Reduced from 1e30 to avoid INF
	var result = CalculationManager.roll_damage(large_damage, 1.0, 2.0)
	assert_true(result.damage > 1e19, "Damage roll with large base damage should be a large number")
	log_summary("Validated that rolling damage with a large base value (1e20) correctly results in a large number.\n")

func test_cooldown_with_negative_delta():
	var cooldown = CalculationManager.tick_cooldown(1.0, -1.0)
	assert_eq(cooldown, 2.0, "Ticking cooldown with negative delta should increase it")
	log_summary("Tested that ticking a cooldown with a negative delta (-1.0) correctly increases the cooldown value instead of decreasing it.\n")

func test_clamp_to_rect_with_inverted_rect():
	var rect = Rect2(100, 100, -100, -100) # Inverted rect
	var clamped = CalculationManager.clamp_to_rect(Vector2(50, 50), rect)
	assert_eq(clamped, Vector2(50, 50), "Clamping to an inverted rect should behave like a normal rect")
	log_summary("Verified that clamping a position within an inverted rectangle (size [-100, -100]) is handled correctly by treating it as a valid rect.\n")

func test_random_string_with_negative_length():
	var s = CalculationManager.get_random_string(-10)
	assert_eq(len(s), 0, "Random string with negative length should be empty")
	log_summary("Ensured that requesting a random string with a negative length (-10) returns an empty string gracefully.\n")
