extends "res://tests/robot/logic_test_case.gd"

const ActorBase = preload("res://src/shared/scripts/actor_base.gd")
const StatBlock = preload("res://src/shared/resources/stat_block.gd")

func get_name() -> String:
	return "ActorHealthTest"

func run_case() -> void:
	var actor = ActorBase.new()
	var stats = StatBlock.new()
	stats.max_hp = 10
	actor.stats = stats
	actor.base_max_hp = 10
	actor.hp = 10
	var source = Node2D.new()

	actor.apply_damage(3.0, source)
	assert_equal(actor.hp, 7.0, "Actor HP reduced after damage")
	assert_true(actor.is_alive, "Actor remains alive after partial damage")

	actor.apply_damage(10.0, source)
	assert_true(actor.hp <= 0.0, "Actor HP clamps at zero")
	assert_false(actor.is_alive, "Actor dies when HP <= 0")
