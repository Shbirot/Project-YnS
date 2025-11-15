extends CharacterBody2D

const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")

@export var max_health := 20.0
@export var move_speed := 140.0
@export var acceleration := 600.0
@export var friction := 400.0
@export var damage := 5.0
@export var xp_orb_scene: PackedScene

var _current_health := 0.0
var _hero: Node2D
var _event_bus: Node

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea

func _ready() -> void:
	_apply_env_overrides()
	_current_health = max_health
	add_to_group("enemies")
	_hero = _find_hero()
	_event_bus = SingletonUtil.get_event_bus()
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_entered)

func _physics_process(delta: float) -> void:
	if _hero == null:
		_hero = _find_hero()
		return
	var direction := (_hero.global_position - global_position).normalized()
	var desired_velocity := direction * move_speed
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	if animated_sprite == null:
		return
	var anim := "walk" if animated_sprite.sprite_frames.has_animation("walk") else "idle"
	animated_sprite.play(anim)
	if abs(direction.x) > abs(direction.y):
		animated_sprite.flip_h = direction.x < 0.0

func apply_damage(source: Node, amount: float) -> void:
	_current_health -= amount
	if _current_health <= 0.0:
		die(source)

func die(_source: Node) -> void:
	if _event_bus:
		_event_bus.emit_safe("enemy_died", [self])
	_spawn_xp()
	queue_free()

func _spawn_xp() -> void:
	if xp_orb_scene == null:
		return
	var orb := xp_orb_scene.instantiate()
	if orb == null:
		return
	call_deferred("_add_orb", orb)

func _add_orb(orb: Node) -> void:
	get_tree().current_scene.add_child(orb)
	orb.global_position = global_position

func _find_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")

func _on_damage_area_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		var damage_system = SingletonUtil.get_damage_system()
		if damage_system:
			damage_system.apply_hero_damage(self, damage)

func _apply_env_overrides() -> void:
	var cfg = SingletonUtil.get_game_config()
	max_health = cfg.get_env_value("NF_ENEMY_MAX_HEALTH", max_health)
	move_speed = cfg.get_env_value("NF_ENEMY_MOVE_SPEED", move_speed)
	acceleration = cfg.get_env_value("NF_ENEMY_ACCELERATION", acceleration)
	friction = cfg.get_env_value("NF_ENEMY_FRICTION", friction)
	damage = cfg.get_env_value("NF_ENEMY_DAMAGE", damage)
