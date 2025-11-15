extends Node

## Enhanced projectile object pool with pre-allocation
## Reduces GC stutter and memory fragmentation

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

const DEFAULT_POOL_SIZE = 50
const MAX_POOL_SIZE = 200

var _pool = {}
var _active_count = {}

func _ready() -> void:
	_preallocate_common_projectiles()

func acquire(scene: PackedScene) -> Node:
	if scene == null:
		return null
	var key = scene.resource_path
	var bucket: Array = _pool.get(key, [])
	var projectile: Node = null

	if bucket.size() > 0:
		projectile = bucket.pop_back()
		_pool[key] = bucket
		if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
			DebugUtils.debug_log("Projectile pool reuse", {"key": key, "remaining": bucket.size()})
	else:
		projectile = scene.instantiate()
		projectile.set_meta("pool_key", key)
		if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
			DebugUtils.debug_log("Projectile pool new instance", {"key": key})

	_active_count[key] = _active_count.get(key, 0) + 1
	return projectile

func release(projectile: Node) -> void:
	if projectile == null:
		return
	var key = projectile.get_meta("pool_key", "")
	if key == "":
		projectile.queue_free()
		return

	# Reset projectile state
	if projectile.has_method("reset"):
		projectile.reset()

	var bucket: Array = _pool.get(key, [])

	# Limit pool size to prevent unbounded growth
	if bucket.size() >= MAX_POOL_SIZE:
		projectile.queue_free()
		if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
			DebugUtils.debug_log("Projectile pool full, destroying", {"key": key})
		return

	# Remove from scene tree but don't free
	if projectile.get_parent():
		projectile.get_parent().remove_child(projectile)

	bucket.append(projectile)
	_pool[key] = bucket
	_active_count[key] = max(0, _active_count.get(key, 0) - 1)

	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("Projectile pool usage", {
			"key": key,
			"pooled": bucket.size(),
			"active": _active_count.get(key, 0)
		})

# Legacy compatibility
func fetch_projectile(scene: PackedScene) -> Node:
	return acquire(scene)

func recycle_projectile(projectile: Node) -> void:
	release(projectile)

func _preallocate_common_projectiles() -> void:
	# Pre-allocate common projectile types
	var common_types = [
		"res://src/features/projectiles/basic_projectile.tscn",
		"res://src/features/projectiles/beam_projectile.tscn",
	]

	for path in common_types:
		if not ResourceLoader.exists(path):
			continue
		var scene = load(path)
		if scene == null:
			continue

		var bucket: Array = []
		for i in range(DEFAULT_POOL_SIZE):
			var instance = scene.instantiate()
			instance.set_meta("pool_key", path)
			bucket.append(instance)

		_pool[path] = bucket
		_active_count[path] = 0

	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("ProjectilePool preallocated", {"types": _pool.size(), "count": DEFAULT_POOL_SIZE})

func _exit_tree() -> void:
	for key in _pool.keys():
		for projectile in _pool[key]:
			if projectile:
				projectile.queue_free()
	_pool.clear()
	_active_count.clear()
