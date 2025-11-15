extends Area2D
class_name AmmoBase

const DebugUtils = preload("res://src/shared/scripts/debug_utils.gd")

@export var lifetime = 1.0
@export var damage = 1.0
@export var hit_count = 1
@export var allow_owner_hit = false

var owner_ref: Node
var _time_alive = 0.0
var _initial_hit_count = 1

func _ready() -> void:
	_initial_hit_count = hit_count
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _physics_process(delta: float) -> void:
	_time_alive += delta
	if lifetime > 0.0 and _time_alive >= lifetime:
		on_lifetime_ended()

func on_pool_acquired() -> void:
	reset_ammo()

func reset_ammo() -> void:
	_time_alive = 0.0
	hit_count = _initial_hit_count
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _on_body_entered(body: Node) -> void:
	_apply_damage(body)

func _on_area_entered(area: Area2D) -> void:
	_apply_damage(area)

func _apply_damage(target: Node) -> void:
	if target == null:
		return
	if owner_ref and target == owner_ref and not allow_owner_hit:
		return
	if target is ActorBase:
		var actor = target as ActorBase
		actor.apply_damage(damage, self)
		# DEBUG-ONLY-START
		DebugUtils.debug_log("Ammo applied damage", {
			"target": actor.name,
			"damage": damage,
			"ammo": name
		})
		# DEBUG-ONLY-END
		on_damage_applied(actor)
		if hit_count > 0:
			hit_count -= 1
			if hit_count == 0:
				on_hit_limit_reached()

func on_damage_applied(_actor: ActorBase) -> void:
	pass

func on_hit_limit_reached() -> void:
	despawn()

func on_lifetime_ended() -> void:
	despawn()

func despawn() -> void:
	queue_free()
