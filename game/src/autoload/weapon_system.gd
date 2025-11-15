extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const WeaponDataRework = preload("res://src/features/weapons/weapon_data.gd")

class WeaponInstance extends RefCounted:
	var data: WeaponDataRework
	var cooldown := 0.0

var _hero: Node
var _instances: Array[WeaponInstance] = []
var _event_bus: Node

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	if _event_bus:
		if not _event_bus.is_connected("hero_spawned", Callable(self, "_on_hero_spawned")):
			_event_bus.connect("hero_spawned", Callable(self, "_on_hero_spawned"))
		if not _event_bus.is_connected("hero_died", Callable(self, "_on_hero_died")):
			_event_bus.connect("hero_died", Callable(self, "_on_hero_died"))
	var level_manager = SingletonUtil.get_level_manager()
	if level_manager:
		if not level_manager.is_connected("leveled_up", Callable(self, "_on_hero_leveled")):
			level_manager.connect("leveled_up", Callable(self, "_on_hero_leveled"))

func _process(delta: float) -> void:
	if _hero == null or _instances.is_empty():
		return
	for instance in _instances:
		instance.cooldown -= delta
		if instance.cooldown <= 0.0:
			if _fire_weapon(instance.data):
				instance.cooldown = _next_cooldown(instance.data)

func register_hero(hero: Node) -> void:
	_hero = hero
	_instances.clear()
	var loadout: Array = []
	if hero.has_method("get_weapon_loadout"):
		loadout = hero.get_weapon_loadout()
	for weapon in loadout:
		if weapon is WeaponDataRework:
			var instance := WeaponInstance.new()
			instance.data = weapon
			instance.cooldown = randf() * _next_cooldown(weapon)
			_instances.append(instance)

func _fire_weapon(weapon_data: WeaponDataRework) -> bool:
	if _hero == null or weapon_data == null:
		return false
	if not _hero.has_method("fire_weapon"):
		return false
	return _hero.fire_weapon(weapon_data)

func _on_hero_spawned(hero: Node) -> void:
	register_hero(hero)

func _on_hero_died(_hero_ref: Node) -> void:
	_hero = null
	_instances.clear()

func _on_hero_leveled(level: int) -> void:
	if _hero == null:
		return
	if not _hero.has_method("next_weapon_unlock"):
		return
	var weapon: WeaponDataRework = _hero.next_weapon_unlock(level)
	if weapon and weapon is WeaponDataRework:
		var instance := WeaponInstance.new()
		instance.data = weapon
		instance.cooldown = _next_cooldown(weapon)
		_instances.append(instance)

func _next_cooldown(weapon: WeaponDataRework) -> float:
	var interval := weapon.get_fire_interval_value()
	var multiplier := 1.0
	if _hero and _hero.has_method("get_attack_speed_multiplier"):
		multiplier = max(0.1, _hero.get_attack_speed_multiplier())
	return max(0.01, interval / multiplier)
