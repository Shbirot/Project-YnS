extends Area2D

class_name LingeringDamageField

@export var damage := 5
@export var tick_rate := 0.5
@export var duration := 2.0

var _timer := 0.0
var _elapsed := 0.0

func _ready() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	_timer += delta
	if _timer >= tick_rate:
		_timer = 0.0
		_damage_enemies()
	if _elapsed >= duration:
		queue_free()

func _damage_enemies() -> void:
	for body in get_overlapping_bodies():
		if body.has_method("apply_damage"):
			body.apply_damage(damage, self)
