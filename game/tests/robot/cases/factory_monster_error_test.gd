extends "res://tests/robot/logic_test_case.gd"

const MonsterFactory = preload("res://scripts/factories/monster_factory.gd")

func get_name() -> String:
	return "FactoryMonsterError"

func run_case() -> void:
	var spec := {
		"id": "missing_monster_scene",
		"scene": "res://scenes/missing_monster.tscn",
	}
	var factory = MonsterFactory.new()
	var monster = factory.create(spec)
	assert_true(monster == null, "MonsterFactory returns null for nonexistent scenes")
	log_summary("MonsterFactory correctly refused to instantiate a monster when the scene path was invalid.")
