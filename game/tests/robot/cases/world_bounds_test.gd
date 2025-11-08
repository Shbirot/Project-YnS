extends "res://tests/robot/logic_test_case.gd"

const WorldBounds = preload("res://scripts/systems/world_bounds.gd")

func get_name() -> String:
	return "WorldBounds"

func run_case() -> void:
	WorldBounds.set_rect(Rect2(-100, -100, 200, 200))
	var body := CharacterBody2D.new()
	body.global_position = Vector2(500, 0)
	WorldBounds.clamp_to_world(body, Vector2(10, 10))
	assert_true(body.global_position.x <= 100, "Clamp applied")
	assert_true(WorldBounds.contains_with_margin(Vector2.ZERO, 10), "Contain margin works")
	log_summary("Configured custom world bounds, clamped an out-of-range body, and confirmed containment checks honor margins.")
