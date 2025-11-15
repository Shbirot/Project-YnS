extends CharacterBody2D

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const WeaponDataRework = preload("res://src/features/weapons/weapon_data.gd")
const StatBlock = preload("res://src/shared/resources/stat_block.gd")

@export var max_speed := 280.0
@export var acceleration := 1600.0
@export var friction := 1800.0
@export var camera_lerp_speed := 8.0
@export var idle_animation := "idle"
@export var breathing_animation := "breathing"
@export var run_animation_prefix := "run_"
@export var run_animation_fallback := "walk"
@export var breathing_threshold := 5.0
@export var max_health := 120.0
@export var projectile_spawn_offset := 32.0
@export var animation_profile: AnimationProfile
@export var animation_speed_scale_env := "NF_ANIM_HERO_SPEED_SCALE"
@export var stats_profile: StatBlock
@export var initial_weapons: Array[Resource] = []
@export var weapon_unlock_order: Array[Resource] = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_target: Node2D = $CameraTarget
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var last_nonzero_input := Vector2.RIGHT
var current_health := 0.0
var _input_override := Vector2.ZERO
var _use_input_override := false
var _event_bus: Node
var _animation_speed_scale := 1.0
var _weapon_unlock_queue: Array[Resource] = []
var _stats := {}
var _attack_speed_multiplier := 1.0
var _attack_power := 10.0
var _crit_rate := 0.0
var _crit_damage := 150.0
var _defense := 0.0
var _avoid_chance := 0.0
var _luck := 0.0
var _hp_regen := 0.0
var _exp_rate := 1.0

func _ready() -> void:
	_apply_env_overrides()
	_apply_animation_profile()
	animated_sprite.play(idle_animation)
	add_to_group("hero")
	current_health = max_health
	_event_bus = SingletonUtil.get_event_bus()
	_initialize_weapons()
	_emit_health_event()

func _physics_process(delta: float) -> void:
	var input_vector := _read_movement_input()
	var is_moving := input_vector.length_squared() > 0.0

	if is_moving:
		last_nonzero_input = input_vector
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	_update_camera_target(delta)
	_update_animation(is_moving, input_vector)

func _read_movement_input() -> Vector2:
	if _use_input_override:
		return _input_override.normalized() if _input_override.length_squared() > 0.0 else Vector2.ZERO
	var vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if vector.length_squared() == 0.0:
		vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)
	if vector.length_squared() > 0.0:
		return vector.normalized()
	return vector

func _update_camera_target(delta: float) -> void:
	if camera_target:
		camera_target.global_position = camera_target.global_position.lerp(global_position, clamp(delta * camera_lerp_speed, 0.0, 1.0))

func _update_animation(is_moving: bool, input_vector: Vector2) -> void:
	if animated_sprite == null:
		return
	if is_moving:
		var direction := _direction_from_vector(input_vector)
		var anim_name := "%s%s" % [run_animation_prefix, direction]
		if animated_sprite.sprite_frames.has_animation(anim_name):
			animated_sprite.play(anim_name)
		elif animated_sprite.sprite_frames.has_animation(run_animation_fallback):
			animated_sprite.play(run_animation_fallback)
		else:
			animated_sprite.play(idle_animation)
	else:
		if velocity.length() > breathing_threshold and animated_sprite.sprite_frames.has_animation(breathing_animation):
			animated_sprite.play(breathing_animation)
		else:
			animated_sprite.play(idle_animation)

func _direction_from_vector(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0.0 else "left"
	else:
		return "down" if dir.y > 0.0 else "up"

func fire_weapon(weapon_data: WeaponDataRework) -> bool:
	if weapon_data == null:
		return false
	if weapon_data.is_melee():
		return _fire_melee_weapon(weapon_data)
	return _fire_ranged_weapon(weapon_data)

func _fire_ranged_weapon(weapon_data: WeaponDataRework) -> bool:
	if weapon_data.projectile_scene == null:
		return false
	var direction := _desired_attack_direction()
	if direction == Vector2.ZERO:
		return false
	var pool = SingletonUtil.get_projectile_pool()
	var projectile = null
	if pool:
		projectile = pool.fetch_projectile(weapon_data.projectile_scene)
	else:
		projectile = weapon_data.projectile_scene.instantiate()
	if projectile == null:
		return false
	projectile.direction = direction.normalized()
	projectile.damage = _calculate_weapon_damage(weapon_data)
	if "speed" in projectile:
		if weapon_data.has_method("get_projectile_speed_value"):
			projectile.speed = weapon_data.get_projectile_speed_value()
		else:
			projectile.speed = weapon_data.projectile_speed
	projectile.owner_ref = self
	var current_world := get_tree().current_scene
	if projectile.get_parent():
		projectile.get_parent().remove_child(projectile)
	current_world.add_child(projectile)
	projectile.global_position = global_position + projectile.direction * projectile_spawn_offset
	if projectile.has_method("on_pool_acquired"):
		projectile.call_deferred("on_pool_acquired")
	if _event_bus:
		_event_bus.emit_safe("projectile_fired", [projectile])
	return true

func _fire_melee_weapon(weapon_data: WeaponDataRework) -> bool:
	if weapon_data.melee_scene == null:
		return false
	var direction := _desired_attack_direction()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var melee_instance = weapon_data.melee_scene.instantiate()
	if melee_instance == null:
		return false
	if not melee_instance.has_method("set_owner") and melee_instance.has_variable("owner_ref"):
		melee_instance.owner_ref = self
	if "owner_ref" in melee_instance:
		melee_instance.owner_ref = self
	if "damage" in melee_instance:
		melee_instance.damage = _calculate_weapon_damage(weapon_data)
	var world := get_tree().current_scene
	if world == null:
		return false
	world.add_child(melee_instance)
	var offset := weapon_data.get_attack_range_value()
	melee_instance.global_position = global_position + direction.normalized() * offset
	if melee_instance.has_method("look_at"):
		melee_instance.look_at(melee_instance.global_position + direction)
	return true

func _find_target_direction() -> Vector2:
	var closest_enemy := _nearest_enemy()
	if closest_enemy:
		return (closest_enemy.global_position - global_position).normalized()
	return Vector2.ZERO

func _desired_attack_direction() -> Vector2:
	var dir := _find_target_direction()
	if dir == Vector2.ZERO and last_nonzero_input.length_squared() > 0.0:
		return last_nonzero_input.normalized()
	return dir

func _nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var min_dist := INF
	var target: Node2D
	for enemy in enemies:
		if not (enemy is Node2D):
			continue
		var d := global_position.distance_squared_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			target = enemy
	return target

func _apply_env_overrides() -> void:
	_apply_stats()
	var cfg = SingletonUtil.get_game_config()
	max_speed = cfg.get_env_value("NF_HERO_MAX_SPEED", max_speed)
	acceleration = cfg.get_env_value("NF_HERO_ACCELERATION", acceleration)
	friction = cfg.get_env_value("NF_HERO_FRICTION", friction)
	camera_lerp_speed = cfg.get_env_value("NF_HERO_CAMERA_LERP", camera_lerp_speed)
	max_health = cfg.get_env_value("NF_HERO_MAX_HEALTH", max_health)
	projectile_spawn_offset = cfg.get_env_value("NF_HERO_PROJECTILE_OFFSET", projectile_spawn_offset)
	_animation_speed_scale = cfg.get_env_value(animation_speed_scale_env, 1.0)
	if animated_sprite:
		animated_sprite.speed_scale = _animation_speed_scale

func _apply_animation_profile() -> void:
	if animated_sprite == null or animation_profile == null:
		return
	var frames := animation_profile.instantiate_frames()
	if frames:
		animated_sprite.sprite_frames = frames
	if animation_profile.default_animation != "":
		idle_animation = animation_profile.default_animation

func _apply_stats() -> void:
	if stats_profile:
		_stats = stats_profile.get_stats()
	else:
		_stats = {}
	max_health = _stats.get("max_hp", max_health)
	max_speed = _stats.get("speed", max_speed)
	_attack_power = _stats.get("attack", _attack_power)
	_attack_speed_multiplier = max(0.1, _stats.get("attack_speed", _attack_speed_multiplier))
	_crit_rate = _stats.get("crit_rate", _crit_rate)
	_crit_damage = _stats.get("crit_damage", _crit_damage)
	_defense = _stats.get("defense", _defense)
	_avoid_chance = _stats.get("avoid_chance", _avoid_chance)
	_luck = _stats.get("luck", _luck)
	_hp_regen = _stats.get("hp_regen", _hp_regen)
	_exp_rate = _stats.get("exp_rate", _exp_rate)

func set_input_override(direction: Vector2) -> void:
	_input_override = direction
	_use_input_override = true

func clear_input_override() -> void:
	_input_override = Vector2.ZERO
	_use_input_override = false

func override_active() -> bool:
	return _use_input_override

func apply_damage(source: Node, amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	_emit_health_event()
	if current_health <= 0.0:
		_die()

func heal(amount: float) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)
	_emit_health_event()

func _emit_health_event() -> void:
	if _event_bus:
		_event_bus.emit_safe("hero_health_changed", [current_health, max_health])

func _die() -> void:
	set_process(false)
	set_physics_process(false)
	if _event_bus:
		_event_bus.emit_safe("hero_died", [self])

func _initialize_weapons() -> void:
	_weapon_unlock_queue = weapon_unlock_order.duplicate()
	if initial_weapons.is_empty():
		var default_weapon := load("res://src/features/weapons/basic_wand.tres")
		if default_weapon:
			initial_weapons.append(default_weapon)
	var weapon_system = SingletonUtil.get_weapon_system()
	if weapon_system:
		weapon_system.register_hero(self)

func get_weapon_loadout() -> Array:
	var loadout: Array = []
	for weapon in initial_weapons:
		if weapon is WeaponDataRework:
			loadout.append(weapon)
	return loadout

func get_primary_weapon() -> WeaponDataRework:
	var loadout := get_weapon_loadout()
	if loadout.is_empty():
		return null
	return loadout[0]

func next_weapon_unlock(_level: int) -> WeaponDataRework:
	if _weapon_unlock_queue.is_empty():
		return null
	var next_weapon: Resource = _weapon_unlock_queue.pop_front()
	if next_weapon is WeaponDataRework:
		initial_weapons.append(next_weapon)
		return next_weapon
	return null

func get_attack_speed_multiplier() -> float:
	return _attack_speed_multiplier

func get_crit_profile() -> Dictionary:
	var profile: Dictionary = {
		"crit_rate": _crit_rate,
		"crit_damage": _crit_damage
	}
	return profile

func get_defense() -> float:
	return _defense

func get_avoid_chance() -> float:
	return _avoid_chance

func get_luck() -> float:
	return _luck

func get_hp_regen_rate() -> float:
	return _hp_regen

func get_exp_rate_multiplier() -> float:
	return _exp_rate

func _calculate_weapon_damage(weapon_data: WeaponDataRework) -> float:
	var base_attack: float = max(0.0, _attack_power)
	var weapon_scalar: float = 1.0
	if weapon_data:
		if weapon_data.has_method("get_damage_value"):
			weapon_scalar = weapon_data.get_damage_value()
		else:
			weapon_scalar = weapon_data.damage
	return max(1.0, base_attack * weapon_scalar)
