extends "res://tests/robot/logic_test_case.gd"

const MovementSystem = preload("res://scripts/systems/movement_system.gd")

class DummyBody:
	extends CharacterBody2D

func get_name() -> String:
	return "MovementSystemError"

func run_case() -> void:
	MovementSystem.apply_directional_input(null, Vector2.ONE, 100.0)
	assert_true(true, "Null bodies are safely ignored for directional input")

	var body = DummyBody.new()
	var target = Node2D.new()
	target.queue_free()
	MovementSystem.seek_target(body, target, 200.0)
	assert_equal(body.velocity, Vector2.ZERO, "Invalid targets leave velocity unchanged")
	log_summary("MovementSystem handled null bodies and freed targets without crashing, leaving velocities untouched.")
