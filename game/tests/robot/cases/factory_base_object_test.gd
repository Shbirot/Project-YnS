extends "res://tests/robot/logic_test_case.gd"

const BaseFactory = preload("res://scripts/factories/base_object_factory.gd")
const YamlLoader = preload("res://tests/robot/utils/yaml_loader.gd")

func get_name() -> String:
	return "FactoryBaseObject"

func run_case() -> void:
	var spec = YamlLoader.load_yaml("res://tests/robot/data/factories/base_object.yml")
	assert_true(not spec.is_empty(), "Base object spec loaded")
	var factory = BaseFactory.new()
	var instance = factory.create(spec)
	assert_true(instance is Node2D, "Instance created from base factory")
	assert_equal(instance.name, spec["id"], "Spec id maps to node name")
	assert_equal(instance.visible, false, "Visibility override applied")
	assert_equal(instance.position, Vector2(42, 64), "Position override applied")
	assert_equal(instance.scale, Vector2(0.5, 0.5), "Scale override applied")
	log_summary("BaseObjectFactory instantiated %s and honored YAML visibility/transform overrides." % spec.get("id", "<unknown>"))
	instance.queue_free()
