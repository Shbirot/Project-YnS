extends "res://src/shared/scripts/actor_base.gd"
class_name MonsterBase

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const StatBlock = preload("res://src/shared/resources/stat_block.gd")

@export var monster_base_hp = 20.0
@export var animation_profile: AnimationProfile
@export var animation_speed_scale_env = "NF_ANIM_ENEMY_SPEED_SCALE"
@export var xp_orb_scene: PackedScene
@export var stats_profile: StatBlock
@export var ai_controller: EnemyAIController
@export var weapon_overrides: Array = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _event_bus: Node
var _enemy_pool: Node
var _animation_speed_scale = 1.0
var _stats = {}
var _hero: Node2D
var _active_ai: EnemyAIController

func _ready() -> void:
	stats = stats_profile
	base_max_hp = monster_base_hp
	super._ready()
	_event_bus = SingletonUtil.get_event_bus()
	_enemy_pool = SingletonUtil.get_enemy_pool()
	_apply_env_overrides()
	_apply_animation_profile()
	add_to_group("enemies")
	_set_active_state(false)
	_hero = _find_hero()
	_apply_weapon_overrides()
	_active_ai = ai_controller
	_on_monster_ready()

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	var hero_target = _hero if _hero else _find_hero()
	if hero_target:
		_hero = hero_target
	var hero_pos = hero_target.global_position if hero_target else Vector2.ZERO
	var direction = _target_direction(hero_target, hero_pos)
	set_move_direction(direction)
	super._physics_process(delta)
	_update_animation(direction)

func process_actor(_delta: float) -> void:
	pass

func prepare_for_spawn(position: Vector2) -> void:
	global_position = position
	revive(true)
	_set_active_state(true)
	_apply_env_overrides()
	_apply_weapon_overrides()
	_active_ai = ai_controller
	_hero = _find_hero()
	_on_spawn_prepared()

func on_pool_recycled() -> void:
	_set_active_state(false)
	_on_recycled()

func configure_from_archetype(archetype: EnemyArchetype) -> void:
	if archetype == null:
		return

	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("Archetype loaded", {"type": archetype.id})

	if archetype.stats:
		stats_profile = archetype.stats
		stats = stats_profile
	_cache_stats()

	# Apply movement profile
	if archetype.movement_profile:
		max_speed = archetype.movement_profile.max_speed
		acceleration = archetype.movement_profile.acceleration
		friction = archetype.movement_profile.friction

	# Apply animation profile
	if archetype.animations:
		animation_profile = archetype.animations
		_apply_animation_profile()

	if archetype.ai_controller:
		ai_controller = archetype.ai_controller
	_active_ai = ai_controller

	if archetype.weapon_slots.size() > 0:
		weapon_overrides = archetype.weapon_slots.duplicate()

	if archetype.scene:
		set_meta("archetype_scene", archetype.scene)

func get_ai_controller() -> EnemyAIController:
	return _active_ai

func _target_direction(hero_ref: Node2D, hero_pos: Vector2) -> Vector2:
	if _active_ai and hero_ref:
		return _active_ai.get_move_direction(self, hero_ref)
	if hero_ref == null:
		return Vector2.ZERO
	return (hero_pos - global_position).normalized()

func _update_animation(direction: Vector2) -> void:
	if animated_sprite == null:
		return
	var anim = "walk" if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("walk") else "idle"
	animated_sprite.play(anim)
	if abs(direction.x) > abs(direction.y):
		animated_sprite.flip_h = direction.x < 0.0

func _apply_env_overrides() -> void:
	_cache_stats()
	var cfg = SingletonUtil.get_game_config()
	base_max_hp = cfg.get_env_value("NF_ENEMY_MAX_HEALTH", base_max_hp)
	max_speed = cfg.get_env_value("NF_ENEMY_MOVE_SPEED", max_speed)
	acceleration = cfg.get_env_value("NF_ENEMY_ACCELERATION", acceleration)
	friction = cfg.get_env_value("NF_ENEMY_FRICTION", friction)
	_animation_speed_scale = cfg.get_env_value(animation_speed_scale_env, 1.0)
	if animated_sprite:
		animated_sprite.speed_scale = _animation_speed_scale
	hp = base_max_hp

func _apply_animation_profile() -> void:
	if animated_sprite == null or animation_profile == null:
		return
	var frames = animation_profile.instantiate_frames()
	if frames:
		animated_sprite.sprite_frames = frames

func _cache_stats() -> void:
	if stats_profile:
		_stats = stats_profile.get_stats()
	else:
		_stats = {}
	base_max_hp = _stats.get("max_hp", base_max_hp)
	max_speed = _stats.get("speed", max_speed)

func get_stat_value(stat_key: String, default_value: float = 0.0) -> float:
	return _stats.get(stat_key, default_value)

func _find_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")

func on_actor_died(source: Node) -> void:
	super.on_actor_died(source)
	if _event_bus:
		_event_bus.emit_safe("enemy_died", [self, source])
	var scene = get_tree().current_scene if get_tree() else null
	_on_monster_died(scene)
	_recycle_self()

func _apply_weapon_overrides() -> void:
	if weapon_overrides.is_empty():
		return
	clear_weapons()
	for weapon in weapon_overrides:
		add_weapon(weapon)

func set_weapon_overrides(weapons: Array) -> void:
	weapon_overrides = weapons.duplicate()
	_apply_weapon_overrides()

func _on_monster_ready() -> void:
	pass

func _on_spawn_prepared() -> void:
	pass

func _on_recycled() -> void:
	pass

func _on_monster_died(scene: Node) -> void:
	call_deferred("_spawn_xp", scene)

func _spawn_xp(scene: Node) -> void:
	if xp_orb_scene == null or scene == null:
		return
	var orb = xp_orb_scene.instantiate()
	if orb == null:
		return
	scene.add_child(orb)
	orb.global_position = global_position

func _recycle_self() -> void:
	if _enemy_pool and _enemy_pool.has_method("recycle_enemy"):
		_enemy_pool.recycle_enemy(self)
	else:
		queue_free()

func _set_active_state(enabled: bool) -> void:
	visible = enabled
	set_process(enabled)
	set_physics_process(enabled)
	if collision_shape:
		collision_shape.set_deferred("disabled", not enabled)
