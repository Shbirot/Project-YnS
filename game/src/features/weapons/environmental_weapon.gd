extends "res://src/features/weapons/weapon_base.gd"
class_name EnvironmentalWeapon

@export var instance_count = 1
@export var spawn_radius = 64.0
@export var attach_to_owner = true

func _spawn_ammo(owner) -> bool:
	var world = _get_world(owner)
	if world == null:
		return false
	var spawned = false
	var total = max(1, instance_count)
	for i in range(total):
		var ammo = ammo_scene.instantiate()
		if ammo == null:
			continue
		_configure_environmental(ammo, owner, i, total)
		if attach_to_owner:
			owner.add_child(ammo)
			ammo.position = _offset_for_index(i, total)
		else:
			if ammo.get_parent():
				ammo.get_parent().remove_child(ammo)
			world.add_child(ammo)
			ammo.global_position = owner.global_position + _offset_for_index(i, total)
		spawned = true
	return spawned

func _configure_environmental(ammo: Node, owner, _index: int, _total: int) -> void:
	if "owner_ref" in ammo:
		ammo.owner_ref = owner
	if "damage" in ammo:
		ammo.damage = _compute_damage(owner)

func _offset_for_index(index: int, total: int) -> Vector2:
	if total <= 1:
		return Vector2(spawn_radius, 0)
	var angle_step = TAU / float(total)
	return Vector2.RIGHT.rotated(angle_step * index) * spawn_radius
