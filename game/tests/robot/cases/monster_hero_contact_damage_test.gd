extends "res://tests/robot/logic_test_case.gd"

const CombatSystem = preload("res://scripts/systems/combat_system.gd")
const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")

class HeroStub:
	extends RefCounted
	func is_in_group(group_name) -> bool:
		return group_name == "heroes"

class MonsterStub:
	extends Object
	var local_hp := 100
	func apply_damage(amount: int, _source) -> void:
		local_hp = max(local_hp - amount, 0)
	func is_in_group(_group_name: String) -> bool:
		return false

func get_name() -> String:
	return "MonsterHeroContactDamage"

func run_case() -> void:
	# Get APIManager singleton
	var api = SingletonUtil.get_api_manager()
	if api == null:
		push_result(false, "APIManager not available")
		return

	# Initialize hero HP through APIManager
	api.set_hero_max_hp(100)
	api.set_hero_hp(100)
	assert_equal(api.get_hero_hp(), 100, "Hero starts at full HP")

	# Create simple stubs for testing routing
	var hero = HeroStub.new()
	var monster = MonsterStub.new()

	# Apply contact damage from monster to hero (simulating collision)
	var applied = CombatSystem.try_contact_damage(monster, hero, 25, true)
	assert_true(applied, "Contact damage was applied")

	# CRITICAL: Verify APIManager/AttributesManager was updated
	var updated_hp = api.get_hero_hp()
	assert_equal(updated_hp, 75, "APIManager updated with hero's current HP after contact damage")

	# Verify monster HP was NOT written to APIManager (monsters manage their own HP locally)
	var monster_hp_before = api.get_hero_hp()
	monster.apply_damage(10, hero)
	var hero_hp_after_monster_damage = api.get_hero_hp()
	assert_equal(hero_hp_after_monster_damage, monster_hp_before, "Monster damage does NOT affect hero HP in APIManager")
	assert_equal(monster.local_hp, 90, "Monster manages own HP locally")

	# Apply more contact damage to hero
	applied = CombatSystem.try_contact_damage(monster, hero, 30, true)
	assert_true(applied, "Second contact damage applied")

	var final_hp = api.get_hero_hp()
	assert_equal(final_hp, 45, "APIManager reflects final hero HP")

	# Test hero_died signal using array capture
	var died_signals := []
	api.hero_died.connect(func(source):
		died_signals.append(source)
	)

	# Apply lethal contact damage
	applied = CombatSystem.try_contact_damage(monster, hero, 100, true)
	assert_true(applied, "Lethal contact damage applied")
	assert_equal(api.get_hero_hp(), 0, "Hero HP at 0 after lethal damage")
	assert_true(died_signals.size() > 0, "hero_died signal emitted on death")

	log_summary("Monster contact damage routes through APIManager correctly (100 -> 75 -> 45 -> 0). Monster local HP separate from hero. Death signal emitted.")
