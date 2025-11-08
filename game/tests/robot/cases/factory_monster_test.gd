extends "res://tests/robot/logic_test_case.gd"

const MonsterFactory = preload("res://scripts/factories/monster_factory.gd")
const YamlLoader = preload("res://tests/robot/utils/yaml_loader.gd")

func get_name() -> String:
	return "FactoryMonster"

func run_case() -> void:
	var spec = YamlLoader.load_yaml("res://tests/robot/data/factories/monster.yml")
	assert_true(not spec.is_empty(), "Monster spec loaded")
	var factory = MonsterFactory.new()
	var monster = factory.create(spec)
	assert_true(monster is CharacterBody2D, "Monster instance created")
	assert_equal(monster.display_name, "YAML Monster", "Display name override applied")
	assert_equal(monster.move_speed, 145.0, "Move speed override applied")
	assert_equal(monster.max_health, 123.0, "Health override applied")
	log_summary("MonsterFactory produced %s with overridden stats from YAML spec." % spec.get("id", "<monster>"))
	monster.queue_free()
