extends Node

## EnemyManager - Maintains list of alive enemies
## Avoids expensive get_nodes_in_group() calls every frame

var _alive_enemies: Array[Node] = []

func register_enemy(enemy: Node) -> void:
	if not _alive_enemies.has(enemy):
		_alive_enemies.append(enemy)

func unregister_enemy(enemy: Node) -> void:
	var idx = _alive_enemies.find(enemy)
	if idx >= 0:
		_alive_enemies.remove_at(idx)

func get_alive_enemies() -> Array[Node]:
	# Clean up invalid references
	var i = _alive_enemies.size() - 1
	while i >= 0:
		if not is_instance_valid(_alive_enemies[i]):
			_alive_enemies.remove_at(i)
		i -= 1
	return _alive_enemies

func get_nearest_enemy(from_position: Vector2) -> Node:
	var enemies = get_alive_enemies()
	if enemies.is_empty():
		return null

	var min_dist_sq = INF
	var nearest: Node = null

	for enemy in enemies:
		if not enemy is Node2D:
			continue
		var dist_sq = from_position.distance_squared_to(enemy.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest = enemy

	return nearest

func get_enemy_count() -> int:
	return get_alive_enemies().size()

func clear() -> void:
	_alive_enemies.clear()
