extends "res://tests/robot/logic_test_case.gd"

const CombatSystem = preload("res://scripts/systems/combat_system.gd")
const HeroCharacter = preload("res://scripts/characters/hero_character.gd")
const MonsterCharacter = preload("res://scripts/characters/monster_character.gd")
const GameController = preload("res://scripts/core/game_controller.gd")

func get_name() -> String:
	return "MonsterHeroContactDamage"

func run_case() -> void:
	# Get the existing GameController (created by test runner)
	var tree = get_tree_ref()
	if tree == null:
		push_result(false, "SceneTree unavailable")
		return

	var controller = tree.root.get_node_or_null("GameController")
	if controller == null:
		push_result(false, "GameController not available")
		return

	# Create hero and add to heroes group
	var hero = HeroCharacter.new()
	hero.name = "TestHero"
	hero.max_health = 100
	hero.add_to_group("heroes")
	tree.root.add_child(hero)
	# _ready() is called automatically when added to tree, but we need to ensure it's processed
	if not hero.is_inside_tree():
		push_result(false, "Hero not in tree after add_child")
		return

	# Verify hero starts at full health
	assert_equal(hero._current_health, 100, "Hero starts at full HP")

	# Verify AttributesManager has initial hero HP
	var initial_hp = controller.get_attribute("hp", -1)
	assert_equal(initial_hp, 100, "AttributesManager initialized with hero HP")

	# Create monster
	var monster = MonsterCharacter.new()
	monster.name = "TestMonster"
	monster.contact_damage = 25
	tree.root.add_child(monster)

	# Apply contact damage from monster to hero (simulating collision)
	var applied = CombatSystem.try_contact_damage(monster, hero, monster.contact_damage, true)
	assert_true(applied, "Contact damage was applied")

	# Verify hero HP decreased
	assert_equal(hero._current_health, 75, "Hero HP decreased by contact damage")

	# CRITICAL: Verify AttributesManager was updated
	var updated_hp = controller.get_attribute("hp", -1)
	assert_equal(updated_hp, 75, "AttributesManager updated with hero's current HP")

	# Verify monster HP was NOT written to AttributesManager
	monster.apply_damage(10, hero)
	var hp_after_monster_damage = controller.get_attribute("hp", -1)
	assert_equal(hp_after_monster_damage, 75, "Monster damage does NOT overwrite hero HP in AttributesManager")

	# Apply more contact damage to hero
	applied = CombatSystem.try_contact_damage(monster, hero, 30, true)
	assert_true(applied, "Second contact damage applied")
	assert_equal(hero._current_health, 45, "Hero HP decreased by second contact damage")

	var final_hp = controller.get_attribute("hp", -1)
	assert_equal(final_hp, 45, "AttributesManager reflects final hero HP")

	# Cleanup
	hero.queue_free()
	monster.queue_free()

	log_summary("Monster contact damage correctly updates hero HP and AttributesManager (100 -> 75 -> 45). Monster damage does not pollute hero attributes.")
