extends RefCounted

class_name CombatSystem

static func apply_damage(target, amount: int, source = null) -> void:
	if amount <= 0 or not is_instance_valid(target):
		return
	if target.has_method("apply_damage"):
		target.apply_damage(amount, source)

static func tick_cooldown(current: float, delta: float) -> float:
	return max(current - delta, 0.0)

static func try_contact_damage(attacker, target, amount: int, cooldown_ready: bool) -> bool:
	if not cooldown_ready:
		return false
	if is_instance_valid(target) and target.has_method("apply_damage"):
		target.apply_damage(amount, attacker)
		return true
	return false
