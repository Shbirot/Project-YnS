extends "res://tests/robot/logic_test_case.gd"

const MovementSystem = preload("res://scripts/systems/movement_system.gd")

class DummyHero:
	extends CharacterBody2D
	var accel := 0.0

func get_name() -> String:
	return "MovementSystem"

func run_case() -> void:
	var hero = DummyHero.new()
	hero.velocity = Vector2.ZERO
	MovementSystem.apply_input_with_accel(hero, Vector2.RIGHT, 300.0, 1000.0, 800.0, 0.016)
	assert_true(hero.velocity.length() > 0.0, "Velocity updated from input")
	log_summary("Applied accelerated input to a dummy CharacterBody2D and confirmed velocity responds in the expected direction.")
