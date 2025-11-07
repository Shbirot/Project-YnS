extends Camera2D

## Smoothly follows a target while respecting optional world bounds.
class_name CameraController

@export var target_path : NodePath
@export var follow_speed := 7.5
@export var world_bounds := Rect2(-2000, -2000, 4000, 4000)

var _target : Node2D

func _ready() -> void:
	if target_path != NodePath():
		_target = get_node_or_null(target_path)
	make_current()
	set_physics_process(true)

func set_target(target: Node2D) -> void:
	_target = target

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_target):
		return
	var desired := _target.global_position
	if world_bounds.size != Vector2.ZERO:
		desired = _clamp_to_bounds(desired)
	global_position = global_position.lerp(desired, clamp(follow_speed * delta, 0.0, 1.0))

func _clamp_to_bounds(pos: Vector2) -> Vector2:
	var min_x = world_bounds.position.x
	var max_x = world_bounds.position.x + world_bounds.size.x
	var min_y = world_bounds.position.y
	var max_y = world_bounds.position.y + world_bounds.size.y
	return Vector2(
		clamp(pos.x, min_x, max_x),
		clamp(pos.y, min_y, max_y)
	)

func set_world_bounds(rect: Rect2) -> void:
	world_bounds = rect
