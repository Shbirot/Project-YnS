extends "res://src/features/weapons/ammo_base.gd"

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var speed = 600.0
@export var hit_effect: PackedScene
@export var max_lifetime = 4.0

var direction = Vector2.RIGHT

@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	lifetime = max_lifetime
	if lifetime_timer:
		lifetime_timer.stop()
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	global_position += direction * speed * delta

func on_damage_applied(_actor: ActorBase) -> void:
	_spawn_hit_effect()

func on_hit_limit_reached() -> void:
	despawn()

func on_lifetime_ended() -> void:
	despawn()

func on_pool_acquired() -> void:
	super.on_pool_acquired()
	set_deferred("visible", true)

func despawn() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	visible = false
	var pool = SingletonUtil.get_projectile_pool()
	if pool:
		pool.recycle_projectile(self)
	else:
		queue_free()

func _spawn_hit_effect() -> void:
	if hit_effect == null:
		return
	var effect = hit_effect.instantiate()
	var world = get_tree().current_scene
	if world:
		world.add_child(effect)
		effect.global_position = global_position

func _return_to_pool() -> void:
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
