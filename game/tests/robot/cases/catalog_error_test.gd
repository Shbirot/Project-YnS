extends "res://tests/robot/logic_test_case.gd"

const ObjectCatalog = preload("res://scripts/factories/object_catalog.gd")

func get_name() -> String:
	return "ObjectCatalogError"

func run_case() -> void:
	var catalog = ObjectCatalog.new()
	catalog.load_catalog("res://config/data/objects/catalog.json")
	var spec = catalog.get_spec("hero", "nonexistent_hero")
	assert_true(spec.is_empty(), "Unknown hero spec returns empty dictionary")
	var instance = catalog.create("hero", "nonexistent_hero")
	assert_true(instance == null, "Catalog returns null when creating unknown entry")
	log_summary("ObjectCatalog gracefully returned empty specs/null nodes for unknown hero identifiers.")
