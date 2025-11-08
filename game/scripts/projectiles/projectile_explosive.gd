extends ProjectileBase

class_name ProjectileExplosive

@export var explosion_radius := 220.0
@export var lingering_duration := 0.0
@export var area_impact_effect : PackedScene
@export var lingering_field_scene : PackedScene = preload("res://scenes/projectiles/lingering_field.tscn")

func _on_impact() -> void:
	_spawn_effect(area_impact_effect)
	_damage_area(global_position, explosion_radius)
	if lingering_duration > 0:
		_spawn_lingering_field()
	super._on_impact()

func _damage_area(center: Vector2, radius: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		if enemy.global_position.distance_to(center) <= radius:
			if enemy.has_method("apply_damage"):
				enemy.apply_damage(damage, self)

func _spawn_lingering_field() -> void:
	if lingering_field_scene == null:
		return
	var field = lingering_field_scene.instantiate()
	field.global_position = global_position
	field.damage = damage * 0.4
	field.duration = lingering_duration
	get_tree().current_scene.add_child(field)
