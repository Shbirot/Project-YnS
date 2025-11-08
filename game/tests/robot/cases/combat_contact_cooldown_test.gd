extends "res://tests/robot/logic_test_case.gd"

const CombatSystem = preload("res://scripts/systems/combat_system.gd")

class TargetStub:
	extends Object
	var total_damage := 0
	func apply_damage(amount, _source):
		total_damage += amount

func get_name() -> String:
	return "CombatContactCooldown"

func run_case() -> void:
	var target := TargetStub.new()
	var attacker := Object.new()
	var applied := CombatSystem.try_contact_damage(attacker, target, 20, false)
	assert_true(applied == false, "Cooldown prevents premature damage")
	assert_equal(target.total_damage, 0, "Target HP unchanged while cooldown active")
	applied = CombatSystem.try_contact_damage(attacker, target, 20, true)
	assert_true(applied == true, "Damage applies once cooldown ready")
	assert_equal(target.total_damage, 20, "Target records damage exactly once")
	log_summary("Contact damage respected cooldown gating; total damage=%d." % target.total_damage)
