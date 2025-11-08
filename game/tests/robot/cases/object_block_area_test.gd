extends "res://tests/robot/logic_test_case.gd"

const MovementSystem = preload("res://scripts/systems/movement_system.gd")
const WorldBounds = preload("res://scripts/systems/world_bounds.gd")

class MovingBodyStub:
	extends CharacterBody2D
	var move_speed := 0.0

func get_name() -> String:
	return "ObjectBlockArea"

func run_case() -> void:
	WorldBounds.set_rect(Rect2(-100, -100, 200, 200))
	var body := MovingBodyStub.new()
	body.global_position = Vector2(95, 0)
	body.move_speed = 180
	var delta := 0.05
	for i in range(6):
		MovementSystem.apply_directional_input(body, Vector2.RIGHT, body.move_speed)
		body.global_position += body.velocity * delta
		WorldBounds.clamp_to_world(body, Vector2.ZERO)
	var rect := WorldBounds.rect
	var max_x := rect.position.x + rect.size.x
	assert_true(body.global_position.x <= max_x + 0.01, "Body never crosses blocking boundary")
	log_summary("World bounds clamped a moving body against the +X edge across multiple frames.")
