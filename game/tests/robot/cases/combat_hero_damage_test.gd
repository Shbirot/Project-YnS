extends "res://tests/robot/logic_test_case.gd"

const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")

func get_name() -> String:
	return "CombatHeroDamage"

func run_case() -> void:
	# Get APIManager singleton
	var api = SingletonUtil.get_api_manager()
	if api == null:
		push_result(false, "APIManager not available")
		return

	# Initialize hero HP through APIManager
	api.set_hero_max_hp(180)
	api.set_hero_hp(180)
	assert_equal(api.get_hero_hp(), 180, "Hero starts at 180 HP")

	# Test hero_hp_changed signal using array capture
	var hp_signals := []
	api.hero_hp_changed.connect(func(current, max_hp):
		hp_signals.append({"current": current, "max": max_hp})
	)

	# Apply damage through APIManager
	api.damage_hero(45, null)
	assert_equal(api.get_hero_hp(), 135, "Hero HP reduced by incoming damage")
	assert_equal(hp_signals.size(), 1, "hero_hp_changed emitted once")
	if hp_signals.size() > 0:
		assert_equal(hp_signals[0]["current"], 135, "Signal emitted correct current HP")
		assert_equal(hp_signals[0]["max"], 180, "Signal emitted correct max HP")

	# Test hero_died signal using array capture
	var died_signals := []
	api.hero_died.connect(func(source):
		died_signals.append(source)
	)

	# Apply lethal damage
	api.damage_hero(200, null)
	assert_equal(api.get_hero_hp(), 0, "Hero HP floors at zero when lethal damage applies")
	assert_true(died_signals.size() > 0, "hero_died signal emitted")
	assert_equal(hp_signals.size(), 2, "hero_hp_changed emitted for lethal damage")

	log_summary("Hero damage routing through APIManager: sequential hits (45 + 200) -> 135 HP then death at 0 HP, signals emitted correctly.")
