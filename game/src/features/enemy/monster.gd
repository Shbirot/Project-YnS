extends CharacterBody2D
class_name Monster

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var max_health := 20.0
@export var move_speed := 140.0
@export var acceleration := 600.0
@export var friction := 400.0
@export var animation_profile: AnimationProfile
@export var animation_speed_scale_env := "NF_ANIM_ENEMY_SPEED_SCALE"

var _current_health := 0.0
var _hero: Node2D
var _event_bus: Node
var _animation_speed_scale := 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	_apply_env_overrides()
	_apply_animation_profile()
	_current_health = max_health
	add_to_group("enemies")
	_hero = _find_hero()
	_on_monster_ready()

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
	_on_monster_died(source)
	queue_free()

func _on_monster_ready() -> void:
	pass

func _on_monster_died(_source: Node) -> void:
	pass

func _find_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")

func _apply_env_overrides() -> void:
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
