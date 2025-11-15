extends "res://src/shared/scripts/actor_base.gd"

@export var hero_base_hp = 120.0
@export var camera_lerp_speed = 8.0
@export var idle_animation = "idle"
@export var breathing_animation = "breathing"
@export var run_animation_prefix = "run_"
@export var run_animation_fallback = "walk"
@export var breathing_threshold = 5.0
@export var animation_profile: AnimationProfile
@export var animation_speed_scale_env = "NF_ANIM_HERO_SPEED_SCALE"
@export var stats_profile = null
@export var initial_weapons: Array = []
@export var weapon_unlock_order: Array = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_target: Node2D = $CameraTarget
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var last_nonzero_input = Vector2.RIGHT
var _event_bus: Node
var _animation_speed_scale = 1.0
var _weapon_unlock_queue: Array = []
var _stats = {}
var _attack_power = 10.0
var _crit_rate = 0.0
var _crit_damage = 150.0
var _defense = 0.0
var _avoid_chance = 0.0
var _luck = 0.0
var _hp_regen = 0.0
var _exp_rate = 1.0
var _current_input = Vector2.ZERO
var _input_debug_timer = 0.0

func _ready() -> void:
	stats = stats_profile
	base_max_hp = hero_base_hp
	super._ready()
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("Hero ready", {"base_hp": hero_base_hp, "stats_profile": stats_profile})
	_apply_env_overrides()
	_apply_animation_profile()
	if animated_sprite:
		animated_sprite.play(idle_animation)
	add_to_group("hero")
	_event_bus = SingletonUtil.get_event_bus()
	_initialize_weapons()
	_emit_health_event()

func _physics_process(delta: float) -> void:
	var input_vector = InputDriver.get_direction()
	_current_input = input_vector
	if input_vector.length_squared() > 0.0:
		last_nonzero_input = input_vector
		_input_debug_timer = 0.0
	else:
		_input_debug_timer += delta
	set_move_direction(input_vector)
	super._physics_process(delta)

func process_actor(delta: float) -> void:
	var is_moving = _current_input.length_squared() > 0.0
	_update_camera_target(delta)
	_update_animation(is_moving, _current_input)

func get_attack_direction() -> Vector2:
	var desired = _desired_attack_direction()
	if desired == Vector2.ZERO:
		return super.get_attack_direction()
	return desired


func _update_camera_target(delta: float) -> void:
	if camera_target:
		camera_target.global_position = camera_target.global_position.lerp(global_position, clamp(delta * camera_lerp_speed, 0.0, 1.0))

func _update_animation(is_moving: bool, input_vector: Vector2) -> void:
	if animated_sprite == null:
		return
	if is_moving:
		var direction = _direction_from_vector(input_vector)
		var anim_name = "%s%s" % [run_animation_prefix, direction]
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

func _desired_attack_direction() -> Vector2:
	var dir = _find_target_direction()
	if dir == Vector2.ZERO and last_nonzero_input.length_squared() > 0.0:
		return last_nonzero_input.normalized()
	return dir

func _find_target_direction() -> Vector2:
	var closest_enemy = _nearest_enemy()
	if closest_enemy:
		return (closest_enemy.global_position - global_position).normalized()
	return Vector2.ZERO

func _nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var min_dist = INF
	var target: Node2D
	for enemy in enemies:
		if not (enemy is Node2D):
			continue
		var d = global_position.distance_squared_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			target = enemy
	return target

func _apply_env_overrides() -> void:
	_cache_stats()
	var cfg = SingletonUtil.get_game_config()
	DebugUtils.debug_log("Hero applying env overrides", {})
	max_speed = cfg.get_env_value("NF_HERO_MAX_SPEED", max_speed)
	acceleration = cfg.get_env_value("NF_HERO_ACCELERATION", acceleration)
	friction = cfg.get_env_value("NF_HERO_FRICTION", friction)
	camera_lerp_speed = cfg.get_env_value("NF_HERO_CAMERA_LERP", camera_lerp_speed)
	base_max_hp = cfg.get_env_value("NF_HERO_MAX_HEALTH", base_max_hp)
	_animation_speed_scale = cfg.get_env_value(animation_speed_scale_env, 1.0)
	if animated_sprite:
		animated_sprite.speed_scale = _animation_speed_scale
	hp = clamp(hp, 0.0, base_max_hp)
	DebugUtils.debug_log("Hero env overrides applied", {
		"max_speed": max_speed,
		"acceleration": acceleration,
		"friction": friction,
		"base_hp": base_max_hp,
	})

func _apply_animation_profile() -> void:
	if animated_sprite == null or animation_profile == null:
		return
	var frames = animation_profile.instantiate_frames()
	if frames:
		animated_sprite.sprite_frames = frames
	if animation_profile.default_animation != "":
		idle_animation = animation_profile.default_animation

func _cache_stats() -> void:
	if stats_profile:
		_stats = stats_profile.get_stats()
	else:
		_stats = {}
	base_max_hp = _stats.get("max_hp", base_max_hp)
	max_speed = _stats.get("speed", max_speed)
	_attack_power = _stats.get("attack", _attack_power)
	_crit_rate = _stats.get("crit_rate", _crit_rate)
	_crit_damage = _stats.get("crit_damage", _crit_damage)
	_defense = _stats.get("defense", _defense)
	_avoid_chance = _stats.get("avoid_chance", _avoid_chance)
	_luck = _stats.get("luck", _luck)
	_hp_regen = _stats.get("hp_regen", _hp_regen)
	_exp_rate = _stats.get("exp_rate", _exp_rate)

func set_input_override(direction: Vector2) -> void:
	InputDriver.set_override(direction)

func clear_input_override() -> void:
	InputDriver.clear_override()

func override_active() -> bool:
	return InputDriver.is_override_active()

func on_health_changed() -> void:
	_emit_health_event()

func on_actor_died(_source: Node) -> void:
	super.on_actor_died(_source)
	set_process(false)
	set_physics_process(false)
	if _event_bus:
		_event_bus.emit_safe("hero_died", [self])

func _emit_health_event() -> void:
	if _event_bus:
		_event_bus.emit_safe("hero_health_changed", [hp, base_max_hp])

func _initialize_weapons() -> void:
	_weapon_unlock_queue = weapon_unlock_order.duplicate()
	if initial_weapons.is_empty():
		var default_weapon = load("res://src/features/weapons/basic_wand.tres")
		if default_weapon:
			initial_weapons.append(default_weapon)
	clear_weapons()
	for weapon in initial_weapons:
		add_weapon(weapon)

func next_weapon_unlock(_level: int):
	if _weapon_unlock_queue.is_empty():
		return null
	return _weapon_unlock_queue.pop_front()

func get_crit_profile() -> Dictionary:
	return {
		"crit_rate": _crit_rate,
		"crit_damage": _crit_damage
	}

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
