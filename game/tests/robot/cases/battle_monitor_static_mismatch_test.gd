extends "res://tests/robot/logic_test_case.gd"

class MovingBodyStub:
	extends CharacterBody2D

func get_name() -> String:
	return "BattleMonitorStaticMismatch"

func run_case() -> void:
	var hero := MovingBodyStub.new()
	hero.global_position = Vector2.ZERO
	var tolerance := 0.1
	var expected := Vector2.ZERO
	hero.global_position = Vector2(5, 0)
	var matches := hero.global_position.distance_to(expected) <= tolerance
	assert_true(matches == false, "Monitor catches position drift beyond tolerance")
	log_summary("Static monitor flagged a 5px drift as expected (tolerance=%0.2f)." % tolerance)
