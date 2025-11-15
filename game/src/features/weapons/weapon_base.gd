extends Resource
class_name WeaponBase

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const ActorBase = preload("res://src/shared/scripts/actor_base.gd")

@export var id = ""
@export var env_prefix = ""
@export var cooldown = 1.0
@export var damage = 1.0
@export var ammo_scene: PackedScene
@export var fire_offset = 32.0

var _cooldown_timer: float = 0.0

func ready_tick(delta: float, _owner) -> void:
	_cooldown_timer = max(0.0, _cooldown_timer - delta)

func try_fire(owner) -> bool:
	if owner == null:
		return false
	if _cooldown_timer > 0.0:
		return false
	if not _can_fire(owner):
		return false
	var fired = _spawn_ammo(owner)
	if fired:
		_cooldown_timer = max(0.01, _get_effective_cooldown(owner))
	return fired

func reset_cooldown() -> void:
	_cooldown_timer = 0.0

func _can_fire(_owner) -> bool:
	return ammo_scene != null

func _spawn_ammo(_owner) -> bool:
	return false

func _get_effective_cooldown(owner) -> float:
	var base_cooldown: float = _get_cooldown_value()
	var attack_speed: float = max(0.1, owner.get_stat("attack_speed", 1.0))
	return base_cooldown / attack_speed

func _get_cooldown_value() -> float:
	return _get_config_value("COOLDOWN", cooldown)

func _compute_damage(owner) -> float:
	var attack_scalar: float = max(0.1, owner.get_stat("attack", 1.0))
	var total: float = max(1.0, damage * attack_scalar)
	return _get_config_value("DAMAGE", total)

func _get_config_value(suffix: String, fallback):
	if env_prefix == "":
		return fallback
	var cfg = SingletonUtil.get_game_config()
	if cfg == null:
		return fallback
	var key = "%s_%s" % [env_prefix, suffix]
	return cfg.get_env_value(key, fallback)

func _get_world(owner) -> Node:
	var tree: SceneTree = owner.get_tree()
	return tree.current_scene if tree else null
