extends CharacterBody2D
class_name ActorBase

@export var stats = null
@export var base_max_hp = 10.0
@export var max_speed = 280.0
@export var acceleration = 1200.0
@export var friction = 800.0
@export var weapon_slots: Array = []

const MAX_WEAPONS = 5

var hp = 0.0
var is_alive = true
var knockback_decay = 6.0

var _move_direction = Vector2.ZERO
var _knockback_velocity = Vector2.ZERO
var _stats_cache: Dictionary = {}
var _equipped_weapons: Array = []
var _weapon_system_registered = false

func _ready() -> void:
	_refresh_stats()
	hp = max(0.0, get_stat("max_hp", base_max_hp))
	if hp <= 0.0:
		hp = base_max_hp
	_sync_weapon_slots()
	_register_with_weapon_system()

func _enter_tree() -> void:
	if _equipped_weapons.is_empty():
		_sync_weapon_slots()

func _exit_tree() -> void:
	_unregister_from_weapon_system()

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	_apply_movement(delta)
	_decay_knockback(delta)
	process_actor(delta)

func process_actor(_delta: float) -> void:
	pass

func on_health_changed() -> void:
	pass

func on_actor_died(_source: Node) -> void:
	is_alive = false
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
	if amount <= 0.0 or not is_alive:
		return
	hp = max(0.0, hp - amount)
	is_alive = hp > 0.0
	on_health_changed()
	if not is_alive:
		on_actor_died(source)

func heal(amount: float) -> void:
	if amount <= 0.0 or not is_alive:
		return
	var max_hp = get_stat("max_hp", base_max_hp)
	hp = clamp(hp + amount, 0.0, max_hp)
	on_health_changed()

func revive(full_hp = true) -> void:
	var max_hp = get_stat("max_hp", base_max_hp)
	hp = max_hp if full_hp else max(1.0, hp)
	is_alive = true
	on_health_changed()
	_register_with_weapon_system()

func get_stat(name: String, default_value: float = 0.0) -> float:
	return _stats_cache.get(name, default_value)

func set_stat_override(name: String, value) -> void:
	_stats_cache[name] = value

func _apply_movement(delta: float) -> void:
	var desired_velocity = _move_direction * max_speed
	if _move_direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	velocity += _knockback_velocity
	move_and_slide()

func _decay_knockback(delta: float) -> void:
	if _knockback_velocity.length_squared() == 0.0:
		return
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)

func _refresh_stats() -> void:
	if stats:
		_stats_cache = stats.get_stats()
	else:
		_stats_cache.clear()
	base_max_hp = _stats_cache.get("max_hp", base_max_hp)
	max_speed = _stats_cache.get("speed", max_speed)

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
