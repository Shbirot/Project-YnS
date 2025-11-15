extends CharacterBody2D
class_name MonsterBase

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")
const StatBlock = preload("res://src/shared/resources/stat_block.gd")

@export var max_health := 20.0
@export var move_speed := 140.0
@export var acceleration := 600.0
@export var friction := 400.0
@export var animation_profile: AnimationProfile
@export var animation_speed_scale_env := "NF_ANIM_ENEMY_SPEED_SCALE"
@export var xp_orb_scene: PackedScene
@export var stats_profile: StatBlock

var _current_health := 0.0
var _hero: Node2D
var _event_bus: Node
var _enemy_pool: Node
var _animation_speed_scale := 1.0
var _stats := {}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	_enemy_pool = SingletonUtil.get_enemy_pool()
	_apply_env_overrides()
	_apply_animation_profile()
	_current_health = max_health
	add_to_group("enemies")
	_set_active_state(false)
	_hero = _find_hero()
	_on_monster_ready()

func prepare_for_spawn(position: Vector2) -> void:
	global_position = position
	_current_health = max_health
	_set_active_state(true)
	_hero = _find_hero()
	_on_spawn_prepared()

func on_pool_recycled() -> void:
	_set_active_state(false)
	_on_recycled()

func _physics_process(delta: float) -> void:
	var direction := _target_direction()
	_apply_movement(direction, delta)
	_update_animation(direction)

func _target_direction() -> Vector2:
	if _hero == null:
		_hero = _find_hero()
		if _hero == null:
			return Vector2.ZERO
	return (_hero.global_position - global_position).normalized()

func _apply_movement(direction: Vector2, delta: float) -> void:
	if direction != Vector2.ZERO:
		var desired_velocity := direction * move_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

func _update_animation(direction: Vector2) -> void:
	if animated_sprite == null:
		return
	var anim := "walk" if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("walk") else "idle"
	animated_sprite.play(anim)
	if abs(direction.x) > abs(direction.y):
		animated_sprite.flip_h = direction.x < 0.0

func apply_damage(_source: Node, amount: float) -> void:
	_current_health -= amount
	if _current_health <= 0.0:
		_die(_source)

func _die(source: Node) -> void:
	if _event_bus:
		_event_bus.emit_safe("enemy_died", [self, source])
	var world := get_tree()
	var scene := world.current_scene if world else null
	_on_monster_died(scene)
	_recycle_self()

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
	var orb := xp_orb_scene.instantiate()
	if orb == null:
		return
	scene.add_child(orb)
	orb.global_position = global_position

func _find_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")

func _apply_env_overrides() -> void:
	if stats_profile:
		_stats = stats_profile.get_stats()
	else:
		_stats = {}
	max_health = _stats.get("max_hp", max_health)
	move_speed = _stats.get("speed", move_speed)
	var cfg = SingletonUtil.get_game_config()
	max_health = cfg.get_env_value("NF_ENEMY_MAX_HEALTH", max_health)
	move_speed = cfg.get_env_value("NF_ENEMY_MOVE_SPEED", move_speed)
	acceleration = cfg.get_env_value("NF_ENEMY_ACCELERATION", acceleration)
	friction = cfg.get_env_value("NF_ENEMY_FRICTION", friction)
	_animation_speed_scale = cfg.get_env_value(animation_speed_scale_env, 1.0)
	if animated_sprite:
		animated_sprite.speed_scale = _animation_speed_scale

func _apply_animation_profile() -> void:
	if animated_sprite == null or animation_profile == null:
		return
	var frames := animation_profile.instantiate_frames()
	if frames:
		animated_sprite.sprite_frames = frames

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

func get_stat_value(stat_key: String, default_value: float = 0.0) -> float:
	return _stats.get(stat_key, default_value)
