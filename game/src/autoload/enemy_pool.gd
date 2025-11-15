extends Node

var _pool = {}

func fetch_enemy(scene: PackedScene) -> Node:
	if scene == null:
		return null
	var key = scene.resource_path
	var bucket: Array = _pool.get(key, [])
	var enemy: Node = null
	if bucket.size() > 0:
		enemy = bucket.pop_back()
		_pool[key] = bucket
	else:
		enemy = scene.instantiate()
		enemy.set_meta("enemy_pool_key", key)
	return enemy

func recycle_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	if enemy.has_method("on_pool_recycled"):
		enemy.on_pool_recycled()
	var parent = enemy.get_parent()
	if parent:
		parent.call_deferred("remove_child", enemy)
	var key = enemy.get_meta("enemy_pool_key")
	if key == null:
		enemy.queue_free()
		return
	var bucket: Array = _pool.get(key, [])
	bucket.append(enemy)
	_pool[key] = bucket

func _exit_tree() -> void:
	for bucket in _pool.values():
		for enemy in bucket:
			if enemy:
				enemy.queue_free()
	_pool.clear()
