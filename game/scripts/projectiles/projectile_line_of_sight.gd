extends ProjectileBase

class_name ProjectileLineOfSight

@export var max_distance := 2000.0
var _traveled := 0.0

func _physics_process(delta: float) -> void:
	var step = direction.normalized() * speed * delta
	position += step
	_traveled += step.length()
	if _traveled >= max_distance:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage, self)
	# do not queue_free so it keeps traveling
