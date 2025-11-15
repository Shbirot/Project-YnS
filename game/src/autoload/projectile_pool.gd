extends Node

var _pool = {}

func fetch_projectile(scene: PackedScene) -> Node:
	if scene == null:
		return null
	var key = scene.resource_path
	var bucket: Array = _pool.get(key, [])
	var projectile: Node = null
	if bucket.size() > 0:
		projectile = bucket.pop_back()
		_pool[key] = bucket
	else:
		projectile = scene.instantiate()
		projectile.set_meta("pool_key", key)
	return projectile

func recycle_projectile(projectile: Node) -> void:
	if projectile == null:
		return
	var key = projectile.get_meta("pool_key")
	if key == null:
		projectile.queue_free()
		return
	projectile.call_deferred("_return_to_pool")
	var bucket: Array = _pool.get(key, [])
	bucket.append(projectile)
	_pool[key] = bucket

func _exit_tree() -> void:
	for key in _pool.keys():
		for projectile in _pool[key]:
			if projectile:
				projectile.queue_free()
	_pool.clear()
