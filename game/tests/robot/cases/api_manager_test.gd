extends "res://tests/robot/logic_test_case.gd"

const ApiManager = preload("res://scripts/core/api_manager.gd")
const AttributesManager = preload("res://scripts/core/attributes_manager.gd")
const GameController = preload("res://scripts/core/game_controller.gd")

func get_name() -> String:
	return "ApiManager"

func run_case() -> void:
	# Create isolated APIManager instance
	var api = ApiManager.new()
	var attributes_mgr = AttributesManager.new()
	var game_controller = GameController.new()

	# Wire up the managers
	api._attributes_manager = attributes_mgr
	api._game_controller = game_controller

	# Test hero HP management
	api.set_hero_max_hp(100)
	api.set_hero_hp(100)
	assert_equal(api.get_hero_hp(), 100, "Hero HP initialized correctly")
	assert_equal(api.get_hero_max_hp(), 100, "Max HP set correctly")

	# Test damage_hero method with signal capture using array (GDScript closure workaround)
	var hp_signals := []  # Array to capture signal emissions
	api.hero_hp_changed.connect(func(current, max_hp):
		hp_signals.append({"current": current, "max": max_hp})
	)

	api.damage_hero(30, null)
	assert_equal(api.get_hero_hp(), 70, "Hero HP reduced by damage")
	assert_true(hp_signals.size() > 0, "hero_hp_changed signal emitted")
	if hp_signals.size() > 0:
		assert_equal(hp_signals[0]["current"], 70, "Signal emitted correct current HP")
		assert_equal(hp_signals[0]["max"], 100, "Signal emitted correct max HP")

	# Test heal_hero method
	hp_signals.clear()
	api.heal_hero(20)
	assert_equal(api.get_hero_hp(), 90, "Hero HP increased by heal")
	assert_true(hp_signals.size() > 0, "hero_hp_changed signal emitted on heal")

	# Test hero_died signal using array capture
	var died_signals := []
	api.hero_died.connect(func(source):
		died_signals.append(source)
	)

	api.damage_hero(90, null)
	assert_equal(api.get_hero_hp(), 0, "Hero HP floored at zero")
	assert_true(died_signals.size() > 0, "hero_died signal emitted")

	# Test attribute management
	api.set_hero_attribute("fire_rate", 0.5)
	assert_equal(api.get_hero_attribute("fire_rate", 0.0), 0.5, "Hero attribute set correctly")

	log_summary("APIManager facade correctly manages hero HP (damage/heal), emits signals (hp_changed/died), and manages attributes.")
