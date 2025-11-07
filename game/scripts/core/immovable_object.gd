extends NonInteractableObject

## Static prop that optionally blocks movement via a configurable square collision.
class_name ImmovableObject

@export var persistent : bool = false
@export var block_square_size : int = 0

var _block_square_size := 0
var blocker : CollisionShape2D

func _ready() -> void:
	blocker = _ensure_blocker()
	set_block_square_size(block_square_size)
	super._ready()
	add_to_group("obstacles")

func set_block_square_size(value: int) -> void:
	_block_square_size = max(value, 0)
	if typeof(Logger) != TYPE_NIL:
		Logger.debug("Obstacle %s block size -> %d" % [name, _block_square_size])
	_update_blocker()

func get_block_square_size() -> int:
	return _block_square_size

func _ensure_blocker() -> CollisionShape2D:
	var node = get_node_or_null("Blocker")
	if node:
		return node
	node = CollisionShape2D.new()
	node.name = "Blocker"
	add_child(node)
	return node

func _update_blocker() -> void:
	if not blocker:
		return
	if _block_square_size <= 0:
		if typeof(Logger) != TYPE_NIL:
			Logger.debug("Obstacle %s non-blocking" % name)
		blocker.shape = null
		return
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(_block_square_size, _block_square_size) * 0.5
	if typeof(Logger) != TYPE_NIL:
		Logger.debug("Obstacle %s blocker extents %s" % [name, shape.extents])
	blocker.shape = shape

func serialize_state() -> Dictionary:
	return {
		"scene": get_scene_file_path(),
		"position": global_position,
		"block_square_size": _block_square_size,
	}

func apply_serialized_state(state: Dictionary) -> void:
	set_block_square_size(state.get("block_square_size", _block_square_size))
	global_position = state.get("position", global_position)
