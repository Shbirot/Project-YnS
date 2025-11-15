extends Node

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const WeaponBase = preload("res://src/features/weapons/weapon_base.gd")
const DebugUtils = preload("res://src/shared/scripts/debug_utils.gd")

var _event_bus: Node
var _actors: Array = []
var _hero

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	if _event_bus:
		if not _event_bus.is_connected("hero_spawned", Callable(self, "_on_hero_spawned")):
			_event_bus.connect("hero_spawned", Callable(self, "_on_hero_spawned"))
		if not _event_bus.is_connected("hero_died", Callable(self, "_on_hero_died")):
			_event_bus.connect("hero_died", Callable(self, "_on_hero_died"))
	var level_manager = SingletonUtil.get_level_manager()
	if level_manager and not level_manager.is_connected("leveled_up", Callable(self, "_on_hero_leveled")):
		level_manager.connect("leveled_up", Callable(self, "_on_hero_leveled"))

func _process(delta: float) -> void:
	if _actors.is_empty():
		return
	for actor in _actors.duplicate():
		if not is_instance_valid(actor):
			_actors.erase(actor)
			continue
		if not actor.is_alive:
			continue
		var weapons: Array = actor.get_equipped_weapons()
		for weapon in weapons:
			if weapon == null:
				continue
			if weapon.has_method("ready_tick"):
				weapon.ready_tick(delta, actor)
			if weapon.has_method("try_fire"):
				weapon.try_fire(actor)

func register_actor(actor) -> void:
	if actor == null:
		return
	if _actors.has(actor):
		return
	_actors.append(actor)
	# DEBUG-ONLY-START
	DebugUtils.debug_log("Registered actor for weapons", {"name": actor.name})
	# DEBUG-ONLY-END
	if actor.is_in_group("hero") or _hero == null:
		_hero = actor

func unregister_actor(actor) -> void:
	if actor == null:
		return
	if _actors.has(actor):
		_actors.erase(actor)
		# DEBUG-ONLY-START
		DebugUtils.debug_log("Unregistered actor for weapons", {"name": actor.name})
		# DEBUG-ONLY-END
	if _hero == actor:
		_hero = null

func _on_hero_spawned(hero: Node) -> void:
	if hero and hero.is_in_group("hero"):
		register_actor(hero)

func _on_hero_died(hero: Node) -> void:
	if hero and hero.is_in_group("hero"):
		unregister_actor(hero)

func _on_hero_leveled(level: int) -> void:
	if _hero == null:
		return
	if not _hero.has_method("next_weapon_unlock"):
		return
	var next_weapon = _hero.next_weapon_unlock(level)
	if next_weapon and next_weapon is WeaponBase:
		_hero.add_weapon(next_weapon)
		var logger = SingletonUtil.get_logger()
		if logger:
			logger.info("Hero unlocked weapon", {"weapon_id": next_weapon.id})
