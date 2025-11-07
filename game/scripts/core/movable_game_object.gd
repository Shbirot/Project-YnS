extends VisualGameObject

## Adds simple movement helpers and facing logic.
class_name MovableGameObject

@export var move_speed := 200.0

func move_dir(direction: Vector2, _delta: float) -> void:
	if direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		return
	velocity = direction.normalized() * move_speed
	move_and_slide()

func face_point(target: Vector2) -> void:
	if sprite and target != global_position:
		sprite.look_at(target)
