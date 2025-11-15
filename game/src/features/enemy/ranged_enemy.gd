extends "res://src/features/enemy/monster_base.gd"

@export var projectile_scene: PackedScene
@export var fire_interval := 1.6
@export var projectile_speed := 340.0
@export var projectile_damage := 6.0
@export var projectile_spawn_offset := 18.0

@onready var fire_timer: Timer = $FireTimer

func _on_monster_ready() -> void:
	var cfg = SingletonUtil.get_game_config()
	var base_attack_speed := get_stat_value("attack_speed", 1.0)
	var base_damage := get_stat_value("attack", projectile_damage)
	fire_interval = cfg.get_env_value("NF_RANGED_FIRE_INTERVAL", fire_interval)
	projectile_speed = cfg.get_env_value("NF_RANGED_PROJECTILE_SPEED", projectile_speed)
	projectile_damage = cfg.get_env_value("NF_RANGED_PROJECTILE_DAMAGE", base_damage)
	projectile_spawn_offset = cfg.get_env_value("NF_RANGED_PROJECTILE_OFFSET", projectile_spawn_offset)
	fire_interval = max(0.1, fire_interval / max(0.1, base_attack_speed))
	if fire_timer:
		fire_timer.wait_time = fire_interval
		if not fire_timer.timeout.is_connected(Callable(self, "_fire_projectile")):
			fire_timer.timeout.connect(Callable(self, "_fire_projectile"))
		fire_timer.stop()

func _on_spawn_prepared() -> void:
	if fire_timer:
		fire_timer.start()

func _on_recycled() -> void:
	if fire_timer:
		fire_timer.stop()

func _fire_projectile() -> void:
	if projectile_scene == null:
		return
	var hero := _hero if _hero else _find_hero()
	if hero == null:
		return
	var direction := (hero.global_position - global_position).normalized()
	if direction == Vector2.ZERO:
		return
	var projectile := _fetch_projectile()
	if projectile == null:
		return
	projectile.direction = direction
	if "damage" in projectile:
		projectile.damage = projectile_damage
	if "speed" in projectile:
		projectile.speed = projectile_speed
	projectile.owner_ref = self
	var world := get_tree().current_scene
	if projectile.get_parent():
		projectile.get_parent().remove_child(projectile)
	world.add_child(projectile)
	projectile.global_position = global_position + direction * projectile_spawn_offset
	if projectile.has_method("on_pool_acquired"):
		projectile.call_deferred("on_pool_acquired")

func _fetch_projectile() -> Node:
	var pool = SingletonUtil.get_projectile_pool()
	if pool:
		return pool.fetch_projectile(projectile_scene)
	return projectile_scene.instantiate()
