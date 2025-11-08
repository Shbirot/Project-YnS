extends "res://tests/robot/logic_test_case.gd"

const CalculationManager = preload("res://scripts/core/calculation_manager.gd")

func get_name() -> String:
	return "CalculationManagerVector"

func run_case() -> void:
	test_velocity_from_direction()
	test_accelerate_velocity()
	test_decelerate_velocity()
	test_advance_position()
	test_clamp_to_rect()
	test_distance()
	log_summary("CalculationManager vector and position functions are correct.")

func test_velocity_from_direction():
	assert_equal(CalculationManager.velocity_from_direction(Vector2.RIGHT, 100), Vector2(100, 0), "Velocity right")
	assert_equal(CalculationManager.velocity_from_direction(Vector2.LEFT, 50), Vector2(-50, 0), "Velocity left")
	assert_equal(CalculationManager.velocity_from_direction(Vector2.UP, 25), Vector2(0, -25), "Velocity up")
	assert_equal(CalculationManager.velocity_from_direction(Vector2.DOWN, 75), Vector2(0, 75), "Velocity down")
	assert_equal(CalculationManager.velocity_from_direction(Vector2.ZERO, 100), Vector2.ZERO, "Velocity zero direction")
	assert_equal(CalculationManager.velocity_from_direction(Vector2.RIGHT, 0), Vector2.ZERO, "Velocity zero speed")
	var diagonal = CalculationManager.velocity_from_direction(Vector2(1, 1), 100)
	assert_true(abs(diagonal.x - 70.71) < 0.01 and abs(diagonal.y - 70.71) < 0.01, "Velocity diagonal")

func test_accelerate_velocity():
	var current = Vector2(50, 0)
	var accelerated = CalculationManager.accelerate_velocity(current, Vector2.RIGHT, 100, 25, 1.0)
	assert_equal(accelerated, Vector2(75, 0), "Accelerate velocity")
	accelerated = CalculationManager.accelerate_velocity(current, Vector2.LEFT, 100, 25, 1.0)
	assert_equal(accelerated, Vector2(25, 0), "Accelerate velocity opposite direction")

func test_decelerate_velocity():
	var current = Vector2(50, 0)
	var decelerated = CalculationManager.decelerate_velocity(current, 25, 1.0)
	assert_equal(decelerated, Vector2(25, 0), "Decelerate velocity")
	decelerated = CalculationManager.decelerate_velocity(current, 75, 1.0)
	assert_equal(decelerated, Vector2.ZERO, "Decelerate velocity to zero")

func test_advance_position():
	var position = Vector2(10, 10)
	var advanced = CalculationManager.advance_position(position, Vector2.RIGHT, 100, 1.0)
	assert_equal(advanced, Vector2(110, 10), "Advance position")

func test_clamp_to_rect():
	var rect = Rect2(0, 0, 100, 100)
	assert_equal(CalculationManager.clamp_to_rect(Vector2(50, 50), rect), Vector2(50, 50), "Clamp inside")
	assert_equal(CalculationManager.clamp_to_rect(Vector2(150, 50), rect), Vector2(100, 50), "Clamp outside x")
	assert_equal(CalculationManager.clamp_to_rect(Vector2(50, 150), rect), Vector2(50, 100), "Clamp outside y")
	assert_equal(CalculationManager.clamp_to_rect(Vector2(-50, -50), rect), Vector2(0, 0), "Clamp outside both")
	var half_extent = Vector2(10, 10)
	assert_equal(CalculationManager.clamp_to_rect(Vector2(150, 50), rect, half_extent), Vector2(90, 50), "Clamp with half extent")

func test_distance():
	assert_equal(CalculationManager.distance(Vector2(0, 0), Vector2(10, 0)), 10, "Distance")
	assert_equal(CalculationManager.distance(Vector2(0, 0), Vector2(0, 10)), 10, "Distance")
	assert_true(abs(CalculationManager.distance(Vector2(0, 0), Vector2(10, 10)) - 14.14) < 0.01, "Distance diagonal")
