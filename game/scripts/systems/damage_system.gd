extends RefCounted

class_name DamageSystem

const Log = preload("res://scripts/utils/log_helper.gd")
const Calc = preload("res://scripts/core/calculation_manager.gd")

static func apply_projectile_damage(target: Node, base_damage: float, damage_type: String, hit_position: Vector2, source = null) -> void:
	if target == null:
		Log.warn("DamageSystem: target nil for damage_type=%s" % damage_type)
		return
	var metrics = _calculate_final_damage(base_damage)
	var final_damage = metrics.damage
	if target.has_method("apply_damage"):
		target.apply_damage(final_damage, source)
	var controller = Engine.get_main_loop().root.get_node_or_null("GameController")
	if controller:
		var dmg_manager = controller.get_damage_number_manager()
		if dmg_manager:
			dmg_manager.show_damage(final_damage, damage_type, metrics.is_crit, hit_position)
		else:
			Log.warn("DamageSystem: damage manager unavailable")
	else:
		Log.warn("DamageSystem: controller unavailable for damage feedback")

static func _calculate_final_damage(base_damage: float) -> Dictionary:
	var controller = Engine.get_main_loop().root.get_node_or_null("GameController")
	var crit_rate := 0.05
	var crit_multiplier := 1.35
	if controller:
		var attrs = controller.get_attributes_manager()
		if attrs:
			crit_rate = attrs.get_attribute("crit_rate", crit_rate)
			crit_multiplier = attrs.get_attribute("crit_multiplier", crit_multiplier)
		else:
			Log.warn("DamageSystem: attributes manager unavailable")
	else:
		Log.warn("DamageSystem: controller missing during damage calculation")
	return Calc.roll_damage(base_damage, crit_rate, crit_multiplier)
