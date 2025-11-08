extends "res://tests/robot/logic_test_case.gd"

const HeroScene = preload("res://scenes/player.tscn")

func get_name() -> String:
	return "CombatHeroDamage"

func run_case() -> void:
	var hero: Node = HeroScene.instantiate()
	hero.max_health = 180
	if hero.has_method("_ready"):
		hero._ready()
	hero.apply_damage(45, null)
	assert_equal(hero._current_health, 135, "Hero HP reduced by incoming damage")
	hero.apply_damage(200, null)
	assert_equal(hero._current_health, 0, "Hero HP floors at zero when lethal damage applies")
	log_summary("Hero took sequential hits (45 + 200) resulting in 135 HP then death at 0 HP as expected.")
	hero.queue_free()
