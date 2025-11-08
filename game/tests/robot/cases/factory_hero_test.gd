extends "res://tests/robot/logic_test_case.gd"

const HeroFactory = preload("res://scripts/factories/hero_factory.gd")
const YamlLoader = preload("res://tests/robot/utils/yaml_loader.gd")

func get_name() -> String:
	return "FactoryHero"

func run_case() -> void:
	var spec = YamlLoader.load_yaml("res://tests/robot/data/factories/hero.yml")
	assert_true(not spec.is_empty(), "Hero spec loaded")
	var factory = HeroFactory.new()
	var hero = factory.create(spec)
	assert_true(hero is Node, "Hero instance created")
	assert_equal(hero.display_name, "YAML Hero", "Hero name override applied")
	assert_equal(hero.move_speed, 275.0, "Hero speed override applied")
	assert_true(hero.equipped_weapon != null, "Equipped weapon assigned")
	assert_equal(hero.equipped_weapon.resource_path, "res://resources/weapons/basic_wand.tres", "Weapon resolved from YAML path")
	log_summary("HeroFactory created %s with custom move speed and weapon from YAML spec." % spec.get("id", "<hero>"))
	hero.queue_free()
