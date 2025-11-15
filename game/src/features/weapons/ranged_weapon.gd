extends "res://src/features/weapons/weapon_base.gd"
class_name RangedWeapon

@export var projectile_speed = 600.0
@export var projectile_count = 1
@export var spread_degrees = 0.0
@export var use_projectile_pool = true

func _spawn_ammo(owner) -> bool:
	var direction = owner.get_attack_direction()
	if direction == Vector2.ZERO:
		direction = owner.get_move_direction()
	if direction == Vector2.ZERO:
		return false
	var world = _get_world(owner)
	if world == null:
		return false
	var fired = false
	var shots = max(1, projectile_count)
	for i in range(shots):
		var shot_dir = _direction_for_shot(direction, shots, i)
		var ammo = _acquire_ammo_instance()
		if ammo == null:
			continue
		_configure_projectile(ammo, owner, shot_dir)
		if ammo.get_parent():
			ammo.get_parent().remove_child(ammo)
		world.add_child(ammo)
		ammo.global_position = owner.global_position + shot_dir * fire_offset
		if ammo.has_method("on_pool_acquired"):
			ammo.call_deferred("on_pool_acquired")
		fired = true
	return fired

func _direction_for_shot(base_dir: Vector2, total: int, index: int) -> Vector2:
	if spread_degrees <= 0.0 or total == 1:
		return base_dir.normalized()
	var half_spread = deg_to_rad(spread_degrees) * 0.5
	var step = 0.0
	if total > 1:
		step = (half_spread * 2.0) / float(total - 1)
	var angle = -half_spread + step * index
	return base_dir.rotated(angle).normalized()

func _acquire_ammo_instance():
	if ammo_scene == null:
		return null
	if use_projectile_pool:
		var pool = SingletonUtil.get_projectile_pool()
		if pool:
			return pool.fetch_projectile(ammo_scene)
	return ammo_scene.instantiate()

func _configure_projectile(ammo: Node, owner, direction: Vector2) -> void:
	if "owner_ref" in ammo:
		ammo.owner_ref = owner
	if "direction" in ammo:
		ammo.direction = direction.normalized()
	if "speed" in ammo:
		ammo.speed = _get_projectile_speed()
	if "damage" in ammo:
		ammo.damage = _compute_damage(owner)

func _get_projectile_speed() -> float:
	return _get_config_value("PROJECTILE_SPEED", projectile_speed)
