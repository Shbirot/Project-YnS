extends CharacterBody2D
class_name ActorBase

@export var stats = null
@export var base_max_hp = 10.0
@export var max_speed = 280.0
@export var acceleration = 1200.0
@export var friction = 800.0
@export var weapon_slots: Array = []

const MAX_WEAPONS = 5

var knockback_decay = 6.0

var _move_direction = Vector2.ZERO
var _knockback_velocity = Vector2.ZERO
var _stats_cache: Dictionary = {}
var _equipped_weapons: Array = []
var _weapon_system_registered = false
var _health_component: HealthComponent

# Cached physics values
var _cached_max_speed: float = 280.0
var _cached_acceleration: float = 1200.0
var _cached_friction: float = 800.0
var _cached_knockback_decay: float = 6.0

func _ready() -> void:
	_refresh_stats()
	_cache_physics_values()
	_setup_health_component()
	_sync_weapon_slots()
	_register_with_weapon_system()

func _enter_tree() -> void:
	if _equipped_weapons.is_empty():
		_sync_weapon_slots()

func _exit_tree() -> void:
	_unregister_from_weapon_system()

func _physics_process(delta: float) -> void:
	if not is_alive():
		return
	_apply_movement(delta)
	_decay_knockback(delta)
	process_actor(delta)

func process_actor(_delta: float) -> void:
	pass

func on_health_changed() -> void:
	pass

func on_actor_died(_source: Node) -> void:
	_unregister_from_weapon_system()

func set_move_direction(direction: Vector2) -> void:
	_move_direction = direction.normalized() if direction.length_squared() > 0.0 else Vector2.ZERO

func apply_knockback(vec: Vector2) -> void:
	_knockback_velocity += vec

func get_move_direction() -> Vector2:
	return _move_direction

func get_attack_direction() -> Vector2:
	return _move_direction

func get_equipped_weapons() -> Array:
	return _equipped_weapons.duplicate()

func add_weapon(weapon) -> void:
	if weapon == null:
		return
	if _equipped_weapons.size() >= MAX_WEAPONS:
		push_warning("ActorBase: max weapon slots reached")
		return
	var copy: Resource = weapon.duplicate(true)
	if copy == null:
		return
	_equipped_weapons.append(copy)

func remove_weapon(weapon) -> void:
	if weapon == null:
		return
	if _equipped_weapons.has(weapon):
		_equipped_weapons.erase(weapon)

func clear_weapons() -> void:
	_equipped_weapons.clear()

func apply_damage(amount: float, source: Node) -> void:
	if _health_component:
		_health_component.apply_damage(amount, source)

func heal(amount: float) -> void:
	if _health_component:
		_health_component.heal(amount)

func revive(full_hp = true) -> void:
	if _health_component:
		_health_component.revive(full_hp)
		_register_with_weapon_system()

func is_alive() -> bool:
	if _health_component:
		return _health_component.is_alive
	return true

func get_hp() -> float:
	if _health_component:
		return _health_component.get_hp()
	return base_max_hp

func get_max_hp() -> float:
	if _health_component:
		return _health_component.get_max_hp()
	return base_max_hp

func get_stat(name: String, default_value: float = 0.0) -> float:
	return _stats_cache.get(name, default_value)

func set_stat_override(name: String, value) -> void:
	_stats_cache[name] = value

func _apply_movement(delta: float) -> void:
	# Use cached values to reduce property access overhead
	var dir_is_zero = (_move_direction.x == 0.0 and _move_direction.y == 0.0)

	if dir_is_zero:
		velocity = velocity.move_toward(Vector2.ZERO, _cached_friction * delta)
	else:
		var desired_velocity = _move_direction * _cached_max_speed
		velocity = velocity.move_toward(desired_velocity, _cached_acceleration * delta)

	# Only add knockback if non-zero
	if _knockback_velocity.x != 0.0 or _knockback_velocity.y != 0.0:
		velocity += _knockback_velocity

	move_and_slide()

func _decay_knockback(delta: float) -> void:
	# Early exit if no knockback
	if _knockback_velocity.x == 0.0 and _knockback_velocity.y == 0.0:
		return

	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, _cached_knockback_decay * delta)

	# Detect NaN velocity
	if is_nan(_knockback_velocity.x) or is_nan(_knockback_velocity.y):
		if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
			DebugUtils.debug_log("Invalid velocity", {"knockback": _knockback_velocity})
		_knockback_velocity = Vector2.ZERO

func _refresh_stats() -> void:
	if stats:
		_stats_cache = stats.get_stats()
	else:
		_stats_cache.clear()
	base_max_hp = _stats_cache.get("max_hp", base_max_hp)
	max_speed = _stats_cache.get("speed", max_speed)

func _cache_physics_values() -> void:
	_cached_max_speed = max_speed
	_cached_acceleration = acceleration
	_cached_friction = friction
	_cached_knockback_decay = knockback_decay

func _sync_weapon_slots() -> void:
	_equipped_weapons.clear()
	for weapon in weapon_slots:
		if weapon == null:
			continue
		var copy: Resource = weapon.duplicate(true)
		if copy:
			_equipped_weapons.append(copy)

func _register_with_weapon_system() -> void:
	if _weapon_system_registered:
		return
	var weapon_system = SingletonUtil.get_weapon_system()
	if weapon_system and weapon_system.has_method("register_actor"):
		weapon_system.register_actor(self)
		_weapon_system_registered = true

func _unregister_from_weapon_system() -> void:
	if not _weapon_system_registered:
		return
	var weapon_system = SingletonUtil.get_weapon_system()
	if weapon_system and weapon_system.has_method("unregister_actor"):
		weapon_system.unregister_actor(self)
	_weapon_system_registered = false

func _setup_health_component() -> void:
	# Check if health component already exists as a child
	for child in get_children():
		if child is HealthComponent:
			_health_component = child
			break

	# Create one if it doesn't exist
	if not _health_component:
		_health_component = HealthComponent.new()
		add_child(_health_component)

	# Set max HP from stats
	var max_hp = get_stat("max_hp", base_max_hp)
	_health_component.base_max_hp = max_hp
	_health_component.hp = max_hp

	# Set callbacks instead of signals (performance optimization)
	_health_component.set_callbacks(
		Callable(self, "_on_health_component_died"),
		Callable(self, "_on_health_component_changed")
	)

func _on_health_component_died(actor: Node) -> void:
	on_actor_died(actor)

func _on_health_component_changed(_actor: Node, _current_hp: float, _max_hp: float) -> void:
	on_health_changed()
