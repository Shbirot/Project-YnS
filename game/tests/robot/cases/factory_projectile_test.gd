extends "res://tests/robot/logic_test_case.gd"

const ProjectileFactory = preload("res://scripts/factories/projectile_factory.gd")
const YamlLoader = preload("res://tests/robot/utils/yaml_loader.gd")

func get_name() -> String:
	return "FactoryProjectile"

func run_case() -> void:
	var spec = YamlLoader.load_yaml("res://tests/robot/data/factories/projectile.yml")
	assert_true(not spec.is_empty(), "Projectile spec loaded")
	var factory = ProjectileFactory.new()
	var projectile = factory.create(spec)
	assert_true(projectile is Area2D, "Projectile instance created")
	assert_equal(projectile.damage, 77, "Damage override applied")
	assert_equal(projectile.speed, 910.0, "Speed override applied")
	assert_equal(projectile.despawn_margin, 25.0, "Despawn margin override applied")
	log_summary("ProjectileFactory instantiated %s and applied YAML overrides for damage/speed/margin." % spec.get("id", "<projectile>"))
	projectile.queue_free()
