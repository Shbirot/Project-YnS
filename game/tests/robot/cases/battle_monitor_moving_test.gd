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
	return "BattleMonitorMovingHero"

func run_case() -> void:
	var hero := _new_body(Vector2.ZERO, 160.0)
	var monster := _new_body(Vector2(300, 0), 100.0)
	var hero_dir := Vector2.RIGHT
	var monster_dir := Vector2.DOWN
	var delta := 0.05
	var steps := 24
	var expected_hero := hero.global_position
	var expected_monster := monster.global_position
	for i in range(steps):
		MovementSystem.apply_directional_input(hero, hero_dir, hero.move_speed)
		MovementSystem.apply_directional_input(monster, monster_dir, monster.move_speed)
		_advance(hero, delta)
		_advance(monster, delta)
	expected_hero += hero_dir * hero.move_speed * delta * steps
	expected_monster += monster_dir * monster.move_speed * delta * steps
	assert_vector_almost_equal(hero.global_position, expected_hero, 0.1, "Hero path prediction matched measured position")
	assert_vector_almost_equal(monster.global_position, expected_monster, 0.1, "Monster path prediction matched measured position")
	log_summary("Moving hero + monster maintained predicted trajectories (%d frames, delta=%0.2f)." % [steps, delta])
