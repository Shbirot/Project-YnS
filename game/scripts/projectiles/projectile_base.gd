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

## Particle system for trail effect (alternative to tail_effect sprite)
@export var trail_particles : PackedScene
## Enable glow shader on this projectile
@export var use_glow_shader := false
## Glow texture/map for shader emission (only used if use_glow_shader is true)
@export var glow_texture : Texture2D
## Glow color for shader (only used if use_glow_shader is true)
@export var glow_color := Color(0.5, 0.8, 1.0, 1.0)
## Glow intensity for shader (only used if use_glow_shader is true)
@export var glow_intensity := 1.5
## Pulse speed for glow shader (only used if use_glow_shader is true)
@export var pulse_speed := 2.0

var damage_source

var _tail_instance : Node
var _active_trail_particles : GPUParticles2D

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	_apply_glow_shader()
	_spawn_on_fire_effect()
	_spawn_tail_effect()
	_spawn_trail_particles()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	if WorldBounds and not WorldBounds.contains_with_margin(global_position, despawn_margin):
		queue_free()

func _on_body_entered(body: Node) -> void:
	DamageSystem.apply_projectile_damage(body, damage, damage_type, global_position, damage_source)
	_on_impact()

func _on_impact() -> void:
	_stop_trail_particles()
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

## Apply glow shader to the projectile sprite if enabled
func _apply_glow_shader() -> void:
	if not use_glow_shader:
		return

	# Find the sprite node (usually Sprite2D child)
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return

	# Load the glow shader
	var shader = load("res://shaders/projectile_glow.gdshader")
	if not shader:
		push_warning("ProjectileBase: Could not load glow shader")
		return

	# Create shader material and apply it
	var material = ShaderMaterial.new()
	material.shader = shader

	# Set shader parameters
	if glow_texture:
		material.set_shader_parameter("glow_map", glow_texture)
	material.set_shader_parameter("glow_color", glow_color)
	material.set_shader_parameter("glow_intensity", glow_intensity)
	material.set_shader_parameter("pulse_speed", pulse_speed)

	sprite.material = material

## Spawn trail particle system if configured
func _spawn_trail_particles() -> void:
	if not trail_particles:
		return

	_active_trail_particles = trail_particles.instantiate() as GPUParticles2D
	if _active_trail_particles:
		add_child(_active_trail_particles)
		_active_trail_particles.emitting = true

## Stop trail particles and let them finish before cleanup
func _stop_trail_particles() -> void:
	if not _active_trail_particles:
		return

	_active_trail_particles.emitting = false
	# Let particles finish their lifetime before cleanup
	# Note: The parent projectile will queue_free, so particles will be cleaned up automatically
