extends Area2D

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@export var speed := 600.0
@export var damage := 5.0
@export var lifetime := 4.0
@export var hit_effect: PackedScene

var direction := Vector2.RIGHT
var owner_ref: Node

@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)
	lifetime_timer.start()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == owner_ref:
		return
	var damage_system = SingletonUtil.get_damage_system()
	if damage_system:
		damage_system.apply_projectile_hit(self, body)
	_spawn_hit_effect()
	_despawn()

func _spawn_hit_effect() -> void:
	if hit_effect == null:
		return
	var effect := hit_effect.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position

func _on_lifetime_timer_timeout() -> void:
	_despawn()

func _despawn() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	visible = false
	lifetime_timer.stop()
	owner_ref = null
	var pool = SingletonUtil.get_projectile_pool()
	if pool:
		pool.recycle_projectile(self)
	else:
		queue_free()

func on_pool_acquired() -> void:
	visible = true
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	lifetime_timer.stop()
	lifetime_timer.start()

func _return_to_pool() -> void:
	var parent := get_parent()
	if parent:
		parent.remove_child(self)
	lifetime_timer.stop()
