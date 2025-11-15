extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

var _event_bus: Node

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()

func apply_projectile_hit(projectile: Node, target: Node) -> void:
	if target == null:
		return
	if target.has_method("apply_damage"):
		target.apply_damage(projectile.damage, projectile.owner_ref)
		if _event_bus:
			_event_bus.emit_safe("enemy_damaged", [target, projectile.damage, projectile.owner_ref])
	else:
		push_warning("DamageSystem: target %s missing apply_damage" % [target.name])

func apply_hero_damage(source: Node, amount: float) -> void:
	var hero = _find_hero()
	if hero and hero.has_method("apply_damage"):
		hero.apply_damage(amount, source)
		if _event_bus:
			_event_bus.emit_safe("hero_damaged", [hero, amount, source])

func _find_hero() -> Node:
	return get_tree().get_first_node_in_group("hero")
