extends Camera2D

const SingletonUtil = preload("res://scripts/utils/singleton_util.gd")

@export var target_path: NodePath
@export var follow_speed := 6.0
@export var world_bounds := Rect2(Vector2(-1024, -1024), Vector2(2048, 2048))

var _target: Node2D

func _ready() -> void:
	if target_path != NodePath():
		_target = get_node_or_null(target_path)
	var config: Node = SingletonUtil.get_game_config()
	if config and config.has_method("get_world_bounds"):
		set_world_bounds(config.get_world_bounds())

func _physics_process(delta: float) -> void:
	if _target == null:
		return
	var desired := _target.global_position
	global_position = global_position.lerp(desired, clamp(delta * follow_speed, 0.0, 1.0))
	_clamp_to_bounds()

func set_target(node: Node) -> void:
	if node is Node2D:
		_target = node
	else:
		push_warning("CameraRig target is not Node2D: %s" % [node])

func clear_target() -> void:
	_target = null

func set_world_bounds(bounds: Rect2) -> void:
	world_bounds = bounds

func _clamp_to_bounds() -> void:
	var min_x := world_bounds.position.x
	var min_y := world_bounds.position.y
	var max_x := world_bounds.position.x + world_bounds.size.x
	var max_y := world_bounds.position.y + world_bounds.size.y
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)
