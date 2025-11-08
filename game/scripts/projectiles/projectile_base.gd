extends Area2D

class_name ProjectileBase

const WorldBounds = preload("res://scripts/systems/world_bounds.gd")
const DamageSystem = preload("res://scripts/systems/damage_system.gd")

@export var speed := 600.0
@export var damage := 10
@export var direction := Vector2.RIGHT
@export var tail_effect : PackedScene
@export var on_fire_effect : PackedScene
@export var on_impact_effect : PackedScene
@export var despawn_margin := 300.0
@export var damage_type := "physical"
var damage_source

var _tail_instance : Node

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	_spawn_on_fire_effect()
	_spawn_tail_effect()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	if WorldBounds and not WorldBounds.contains_with_margin(global_position, despawn_margin):
		queue_free()

func _on_body_entered(body: Node) -> void:
	DamageSystem.apply_projectile_damage(body, damage, damage_type, global_position, damage_source)
	_on_impact()

func _on_impact() -> void:
	_spawn_effect(on_impact_effect)
	queue_free()

func _spawn_tail_effect() -> void:
	if tail_effect:
		_tail_instance = _spawn_effect(tail_effect)

func _spawn_on_fire_effect() -> void:
	_spawn_effect(on_fire_effect)

func _spawn_effect(effect_scene: PackedScene) -> Node:
	if effect_scene == null:
		return null
	var inst = effect_scene.instantiate()
	add_child(inst)
	return inst
