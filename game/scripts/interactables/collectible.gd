extends StaticEntity
class_name Collectible

const InteractionSystem = preload("res://scripts/systems/interaction_system.gd")

@export var pickup_sound : AudioStream

func _ready() -> void:
	# Set properties for collectibles
	physics_mode = PhysicsMode.STATIC
	collision_mode = CollisionMode.SENSOR
	movement_mode = MovementMode.STATIC
	interaction_type = InteractionType.COLLECTIBLE
	render_tier = RenderTier.IMPORTANT

	super._ready()

	# Configure interaction area for collectible behavior
	if interaction_area:
		interaction_area.monitoring = true
		interaction_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not is_enabled:
		return
	if InteractionSystem.can_collect(self, body):
		InteractionSystem.handle_collectible(self, body)

func apply_effect(_actor) -> void:
	Log.info("%s collected %s" % [_actor.name, display_name])
	_disable()

func _disable() -> void:
	is_enabled = false
	if interaction_area:
		interaction_area.monitoring = false
	visible = false
	set_process(false)
