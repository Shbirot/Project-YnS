extends "res://tests/robot/logic_test_case.gd"

const MonsterScene = preload("res://scenes/enemy.tscn")

func get_name() -> String:
	return "CombatMonsterDamage"

func run_case() -> void:
	var monster: Node = MonsterScene.instantiate()
	monster.max_health = 140
	if monster.has_method("_ready"):
		monster._ready()
	monster.apply_damage(60, null)
	assert_equal(monster._current_health, 80, "Monster health deducted correctly")
	monster.apply_damage(90, null)
	assert_equal(monster._current_health, 0, "Monster HP hits zero when cumulative damage exceeds max")
	log_summary("Monster consumed 60 + 90 damage and ended at 0 HP, matching the expected deductions.")
	monster.queue_free()
