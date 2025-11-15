extends "res://tests/robot/logic_test_case.gd"

const EnemyChaseAI = preload("res://src/features/enemy/ai/chase_ai.gd")
const EnemyKiteAI = preload("res://src/features/enemy/ai/kite_ai.gd")
const MonsterBase = preload("res://src/features/enemy/monster_base.gd")
const ActorBase = preload("res://src/shared/scripts/actor_base.gd")

func get_name() -> String:
	return "EnemyAIDirectionTest"

func run_case() -> void:
	var hero = ActorBase.new()
	hero.global_position = Vector2.ZERO
	var monster = MonsterBase.new()
	monster.global_position = Vector2(10, 0)

	var chase_ai = EnemyChaseAI.new()
	var chase_dir = chase_ai.get_move_direction(monster, hero)
	assert_vector_almost_equal(chase_dir, Vector2(-1, 0), 0.01, "Chase AI moves toward hero")

	var kite_ai = EnemyKiteAI.new()
	kite_ai.preferred_distance = 200.0
	kite_ai.tolerance = 20.0

	monster.global_position = Vector2(400, 0)
	var kite_dir_far = kite_ai.get_move_direction(monster, hero)
	assert_vector_almost_equal(kite_dir_far, Vector2(-1, 0), 0.01, "Kite AI approaches when too far")

	monster.global_position = Vector2(50, 0)
	var kite_dir_close = kite_ai.get_move_direction(monster, hero)
	assert_vector_almost_equal(kite_dir_close, Vector2(1, 0), 0.01, "Kite AI retreats when too close")
