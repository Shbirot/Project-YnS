extends "res://tests/robot/logic_test_case.gd"

class MovingBodyStub:
	extends CharacterBody2D
	var move_speed := 0.0

func get_name() -> String:
	return "BattleMonitorMovingMismatch"

func run_case() -> void:
	var hero := MovingBodyStub.new()
	hero.global_position = Vector2.ZERO
	hero.move_speed = 120.0
	var delta := 0.05
	var steps := 10
	var predicted := Vector2.ZERO
	for i in range(steps):
		hero.velocity = Vector2.RIGHT * hero.move_speed
		hero.global_position += hero.velocity * delta
	# Monitoring bug: prediction forgot to multiply by delta
	predicted = Vector2.RIGHT * hero.move_speed * steps
	var matches := hero.global_position.distance_to(predicted) <= 0.1
	assert_true(matches == false, "Moving monitor detects prediction bug when delta ignored")
	log_summary("Moving monitor saw %s vs %s and correctly treated it as a mismatch." % [hero.global_position, predicted])
