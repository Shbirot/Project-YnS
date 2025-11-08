extends ProjectileBase

class_name ProjectileBouncy

@export var max_bounces := 3
@export var bounce_range := 600.0

var _bounces := 0

func _on_body_entered(body: Node) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage, self)
	_bounces += 1
	if _bounces >= max_bounces:
		_spawn_effect(on_impact_effect)
		queue_free()
	else:
		var target = _find_next_target()
		if target:
			direction = (target.global_position - global_position).normalized()
		else:
			queue_free()

func _find_next_target() -> Node2D:
	var closest : Node2D
	var closest_dist := INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D or enemy == self:
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist and dist <= bounce_range:
			closest_dist = dist
			closest = enemy
	return closest
