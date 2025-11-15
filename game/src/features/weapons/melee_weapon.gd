extends "res://src/features/weapons/weapon_base.gd"
class_name MeleeWeapon

@export var arc_count = 1
@export var arc_spread_degrees = 60.0
@export var allow_owner_hit = false

func _spawn_ammo(owner: ActorBase) -> bool:
	var direction = owner.get_attack_direction()
	if direction == Vector2.ZERO:
		direction = owner.get_move_direction()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var world = _get_world(owner)
	if world == null:
		return false
	var fired = false
	var total = max(1, arc_count)
	for i in range(total):
		var swing_dir = _direction_for_index(direction, total, i)
		var ammo = ammo_scene.instantiate()
		if ammo == null:
			continue
		_configure_melee(ammo, owner, swing_dir)
		if ammo.get_parent():
			ammo.get_parent().remove_child(ammo)
		world.add_child(ammo)
		ammo.global_position = owner.global_position + swing_dir * fire_offset
		fired = true
	return fired

func _direction_for_index(direction: Vector2, total: int, index: int) -> Vector2:
	if total <= 1 or arc_spread_degrees <= 0.0:
		return direction.normalized()
	var full_spread = deg_to_rad(arc_spread_degrees)
	var step = 0.0
	if total > 1:
		step = full_spread / max(1, total - 1)
	var angle = -full_spread * 0.5 + step * index
	return direction.rotated(angle).normalized()

func _configure_melee(ammo: Node, owner: ActorBase, direction: Vector2) -> void:
	if "owner_ref" in ammo:
		ammo.owner_ref = owner
	if "damage" in ammo:
		ammo.damage = _compute_damage(owner)
	if "allow_owner_hit" in ammo:
		ammo.allow_owner_hit = allow_owner_hit
	if "rotation" in ammo:
		ammo.rotation = direction.angle()
