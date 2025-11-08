extends "res://tests/robot/logic_test_case.gd"

const HeroFactory = preload("res://scripts/factories/hero_factory.gd")

func get_name() -> String:
	return "FactoryHeroError"

func run_case() -> void:
	var spec := {
		"id": "hero_with_bad_weapon",
		"scene": "res://scenes/player.tscn",
		"properties": {
			"display_name": "Broken Hero",
			"equipped_weapon": "res://resources/weapons/this_is_missing.tres",
		},
	}
	var factory = HeroFactory.new()
	var hero = factory.create(spec)
	assert_true(hero != null, "Hero instance still spawns even with bad weapon")
	assert_equal(hero.display_name, "Broken Hero", "Non-weapon properties still applied")
	assert_true(hero.equipped_weapon != null, "Hero retained default weapon resource")
	assert_equal(hero.equipped_weapon.resource_path, "res://resources/weapons/basic_wand.tres", "Invalid weapon path ignored by factory")
	log_summary("HeroFactory ignored an invalid weapon resource while still honoring other overrides, keeping the default wand equipped.")
	hero.queue_free()
