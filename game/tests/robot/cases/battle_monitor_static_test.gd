extends "res://tests/robot/logic_test_case.gd"

const MovementSystem = preload("res://scripts/systems/movement_system.gd")

class MovingBodyStub:
	extends CharacterBody2D
	var move_speed := 0.0

func _new_body(position: Vector2, speed: float) -> MovingBodyStub:
	var body := MovingBodyStub.new()
	body.global_position = position
	body.move_speed = speed
	return body

func _advance(body: MovingBodyStub, delta: float) -> void:
	body.global_position += body.velocity * delta

func get_name() -> String:
	return "BattleMonitorStaticHero"

func run_case() -> void:
	var hero := _new_body(Vector2.ZERO, 0.0)
	var monster := _new_body(Vector2(200, 0), 120.0)
	var delta := 0.05
	var steps := 20
	var expected_monster := monster.global_position
	for i in range(steps):
		MovementSystem.apply_directional_input(monster, Vector2.UP, monster.move_speed)
		MovementSystem.apply_directional_input(hero, Vector2.ZERO, hero.move_speed)
		_advance(monster, delta)
		_advance(hero, delta)
	expected_monster += Vector2.UP * monster.move_speed * delta * steps
	assert_vector_almost_equal(monster.global_position, expected_monster, 0.1, "Monster stayed on monitored path")
	assert_vector_almost_equal(hero.global_position, Vector2.ZERO, 0.01, "Hero remained locked in place")
	log_summary("Static hero vs wandering monster stayed aligned with predicted positions over %d frames." % steps)
