extends Node

## EffectPool - Object pool for VFX and spawn effects
## Reduces GC spikes from instantiating effects

const DEFAULT_POOL_SIZE = 20
const MAX_POOL_SIZE = 100

var _pool: Dictionary = {}
var _active_count: Dictionary = {}

func acquire(scene: PackedScene) -> Node:
	if scene == null:
		return null

	var key = scene.resource_path
	var bucket: Array = _pool.get(key, [])

	var effect: Node = null
	if bucket.size() > 0:
		effect = bucket.pop_back()
		_pool[key] = bucket
	else:
		effect = scene.instantiate()
		effect.set_meta("pool_key", key)

	# Reset effect properties
	if effect is Node2D:
		effect.visible = true
		effect.position = Vector2.ZERO
		effect.rotation = 0.0
		effect.scale = Vector2.ONE

	_active_count[key] = _active_count.get(key, 0) + 1
	return effect

func release(effect: Node) -> void:
	if effect == null:
		return

	var key = effect.get_meta("pool_key", "")
	if key == "":
		effect.queue_free()
		return

	var bucket: Array = _pool.get(key, [])

	# Limit pool size
	if bucket.size() >= MAX_POOL_SIZE:
		effect.queue_free()
		return

	# Reset visibility and remove from tree
	if effect is Node2D:
		effect.visible = false

	if effect.get_parent():
		effect.get_parent().remove_child(effect)

	bucket.append(effect)
	_pool[key] = bucket
	_active_count[key] = max(0, _active_count.get(key, 0) - 1)

func preallocate(scene: PackedScene, count: int = DEFAULT_POOL_SIZE) -> void:
	if scene == null:
		return

	var key = scene.resource_path
	var bucket: Array = _pool.get(key, [])

	for i in range(count):
		var instance = scene.instantiate()
		instance.set_meta("pool_key", key)
		if instance is Node2D:
			instance.visible = false
		bucket.append(instance)

	_pool[key] = bucket
	_active_count[key] = 0

func _exit_tree() -> void:
	for key in _pool.keys():
		for effect in _pool[key]:
			if effect:
				effect.queue_free()
	_pool.clear()
	_active_count.clear()
