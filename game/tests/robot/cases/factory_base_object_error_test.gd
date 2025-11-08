extends "res://tests/robot/logic_test_case.gd"

const BaseFactory = preload("res://scripts/factories/base_object_factory.gd")

func get_name() -> String:
	return "FactoryBaseObjectError"

func run_case() -> void:
	var factory = BaseFactory.new()
	var missing_scene_spec := {"id": "bad_without_scene"}
	var instance = factory.create(missing_scene_spec)
	assert_true(instance == null, "Factory returns null when scene key missing")

	var missing_resource_spec := {
		"id": "bad_with_scene",
		"scene": "res://this/does/not/exist.tscn",
	}
	instance = factory.create(missing_resource_spec)
	assert_true(instance == null, "Factory returns null when scene resource missing")

	log_summary("BaseObjectFactory rejected specs lacking a scene path or referencing nonexistent resources.")
