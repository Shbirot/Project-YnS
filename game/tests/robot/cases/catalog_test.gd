extends "res://tests/robot/logic_test_case.gd"

const ObjectCatalog = preload("res://scripts/factories/object_catalog.gd")

func get_name() -> String:
	return "ObjectCatalog"

func run_case() -> void:
	var catalog = ObjectCatalog.new()
	catalog.load_catalog("res://config/data/objects/catalog.json")
	var hero_spec = catalog.get_spec("hero", "hero_arcane")
	assert_true(hero_spec.has("name"), "Loaded hero spec")
	var weapon_spec = catalog.get_spec("weapon", "weapon_arcane_wand")
	assert_true(weapon_spec.has("resource"), "Loaded weapon spec")
	log_summary("Loaded hero_arcane and weapon_arcane_wand specs from catalog.json and verified their key fields.")
