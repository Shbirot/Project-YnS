extends RefCounted

class_name CombatSystem

const Calc = preload("res://scripts/core/calculation_manager.gd")

static func apply_damage(target, amount: int, source = null) -> void:
	if amount <= 0 or not is_instance_valid(target):
		return
	if target.has_method("apply_damage"):
		target.apply_damage(amount, source)

static func tick_cooldown(current: float, delta: float) -> float:
	return Calc.tick_cooldown(current, delta)

static func try_contact_damage(attacker, target, amount: int, cooldown_ready: bool) -> bool:
	if not cooldown_ready:
		return false
	if is_instance_valid(target) and target.has_method("apply_damage"):
		target.apply_damage(amount, attacker)
		return true
	return false
