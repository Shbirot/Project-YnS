extends StaticEntity
class_name ImmovableObject

@export var persistent : bool = false
@export var block_square_size : int = 0

var _block_square_size := 0
var blocker : CollisionShape2D

func _ready() -> void:
	# Set properties for obstacles
	physics_mode = PhysicsMode.STATIC
	collision_mode = CollisionMode.PHYSICAL
	movement_mode = MovementMode.STATIC
	interaction_type = InteractionType.NONE
	render_tier = RenderTier.IMPORTANT

	super._ready()

	# Check for existing CollisionShape2D in scene (either direct child or in StaticBody2D)
	var existing_blocker = get_node_or_null("Blocker")
	if not existing_blocker and static_body:
		existing_blocker = static_body.get_node_or_null("CollisionShape2D")

	# Use existing blocker or the one created by StaticEntity
	blocker = existing_blocker if existing_blocker else collision_shape

	set_block_square_size(block_square_size)
	add_to_group("obstacles")

func set_block_square_size(value: int) -> void:
	_block_square_size = max(value, 0)
	Log.debug("Obstacle %s block size -> %d" % [name, _block_square_size])
	_update_blocker()

func get_block_square_size() -> int:
	return _block_square_size

func _update_blocker() -> void:
	if not blocker:
		return
	if _block_square_size <= 0:
		Log.debug("Obstacle %s non-blocking" % name)
		blocker.shape = null
		return
	var shape = RectangleShape2D.new()
	shape.size = Vector2(_block_square_size, _block_square_size)
	Log.debug("Obstacle %s blocker size %s" % [name, shape.size])
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
