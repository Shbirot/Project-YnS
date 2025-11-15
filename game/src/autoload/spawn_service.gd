extends Node

## SpawnService - Unified spawning logic for enemies, projectiles, and effects
## Reduces duplication and enables better object pooling

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

func spawn_enemy(archetype: EnemyArchetype, position: Vector2, parent: Node = null) -> Node:
	if archetype == null:
		return null

	var enemy_pool = SingletonUtil.get_enemy_pool()
	var scene = archetype.scene
	if scene == null:
		if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
			DebugUtils.debug_log("Spawn enemy missing scene", {"archetype": archetype.id})
		return null

	var enemy: Node = null
	if enemy_pool and enemy_pool.has_method("fetch_enemy"):
		enemy = enemy_pool.fetch_enemy(scene)
	else:
		enemy = scene.instantiate()

	if enemy == null:
		return null

	# Configure from archetype
	if enemy.has_method("configure_from_archetype"):
		enemy.configure_from_archetype(archetype)

	# Set position
	if enemy.has_method("prepare_for_spawn"):
		enemy.prepare_for_spawn(position)
	else:
		enemy.global_position = position

	# Add to scene
	var target_parent = parent if parent else get_tree().current_scene
	if target_parent:
		target_parent.add_child(enemy)

	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("Spawn enemy", {"archetype": archetype.id, "pos": position})

	return enemy

func spawn_projectile(scene: PackedScene, position: Vector2, direction: Vector2, parent: Node = null) -> Node:
	if scene == null:
		return null

	var projectile_pool = SingletonUtil.get_node_or_null("ProjectilePool")
	var projectile: Node = null

	if projectile_pool and projectile_pool.has_method("acquire"):
		projectile = projectile_pool.acquire(scene)
	else:
		projectile = scene.instantiate()

	if projectile == null:
		return null

	projectile.global_position = position

	# Set direction if supported
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	elif "direction" in projectile:
		projectile.direction = direction

	# Add to scene
	var target_parent = parent if parent else get_tree().current_scene
	if target_parent:
		target_parent.add_child(projectile)

	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("Spawn projectile", {"scene": scene.resource_path, "pos": position})

	return projectile

func spawn_effect(scene: PackedScene, position: Vector2, parent: Node = null) -> Node:
	if scene == null:
		return null

	var effect = scene.instantiate()
	if effect == null:
		return null

	effect.global_position = position

	# Add to scene
	var target_parent = parent if parent else get_tree().current_scene
	if target_parent:
		target_parent.add_child(effect)

	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("Spawn effect", {"scene": scene.resource_path, "pos": position})

	return effect
