extends "res://tests/robot/logic_test_case.gd"

const CombatSystem = preload("res://scripts/systems/combat_system.gd")
const MockFactory = preload("res://tests/robot/mocks/mock_factory.gd")

func get_name() -> String:
	return "CombatSystem"

func run_case() -> void:
	test_apply_damage()
	test_try_contact_damage()
	log_summary("CombatSystem correctly applies damage and handles contact damage cooldowns.")

func test_apply_damage():
	var mock_target = MockFactory.create_damageable()
	CombatSystem.apply_damage(mock_target, 10)
	assert_equal(mock_target.damage_taken, 10, "Apply damage")
	CombatSystem.apply_damage(mock_target, -10)
	assert_equal(mock_target.damage_taken, 10, "Apply negative damage does nothing")
	mock_target.free()

func test_try_contact_damage():
	var mock_attacker = Node.new()
	var mock_target = MockFactory.create_damageable()
	var result = CombatSystem.try_contact_damage(mock_attacker, mock_target, 10, true)
	assert_true(result, "Contact damage applied")
	assert_equal(mock_target.damage_taken, 10, "Contact damage amount")
	result = CombatSystem.try_contact_damage(mock_attacker, mock_target, 10, false)
	assert_true(not result, "Contact damage not applied when on cooldown")
	assert_equal(mock_target.damage_taken, 10, "Contact damage amount unchanged")
	mock_attacker.free()
	mock_target.free()
