extends PhysicsEntity
class_name Character

const NodeUtil = preload("res://scripts/utils/node_util.gd")

## NOTE: Heroes no longer manage HP locally - see APIManager
## Monsters still use local HP via _current_health

signal health_changed(current, max)  # Monsters only
signal died  # Monsters only

@export var max_health := 100
@export var base_damage := 10
@export var team := "neutral"

## Local HP for MONSTERS only (heroes use APIManager)
var _current_health := 0

func _ready() -> void:
	# Set default properties for characters
	physics_mode = PhysicsMode.KINEMATIC
	collision_mode = CollisionMode.PHYSICAL
	movement_mode = MovementMode.VELOCITY
	render_tier = RenderTier.CRITICAL

	# Store stats in dictionary
	stats["max_health"] = max_health
	stats["base_damage"] = base_damage
	stats["team"] = team

	super._ready()

	# Only initialize local HP for monsters (heroes use APIManager)
	if not is_in_group("heroes"):
		_current_health = max_health
		health_changed.emit(_current_health, max_health)

## Apply damage (MONSTERS ONLY - heroes go through APIManager)
func apply_damage(amount: int, source = null) -> void:
	if is_in_group("heroes"):
		Log.warn("Character.apply_damage called on hero - should use APIManager!")
		return

	var source_name = NodeUtil.get_display_name(source)
	if amount <= 0:
		Log.warn("DAMAGE REJECTED: %s received zero/negative damage (%d) from %s" % [display_name, amount, source_name])
		return
	if not is_enabled:
		Log.warn("DAMAGE REJECTED: %s is disabled, cannot take damage from %s" % [display_name, source_name])
		return

	var old_hp = _current_health
	_current_health = max(_current_health - amount, 0)
	health_changed.emit(_current_health, max_health)

	Log.info("DAMAGE APPLIED: %s took %d damage (%d->%d) from %s" % [
		display_name, amount, old_hp, _current_health, source_name
	])

	if _current_health <= 0:
		_emit_death(source)

## Heal (MONSTERS ONLY - heroes use APIManager)
func heal(amount: int) -> void:
	if is_in_group("heroes"):
		Log.warn("Character.heal called on hero - should use APIManager!")
		return

	_current_health = clamp(_current_health + amount, 0, max_health)
	health_changed.emit(_current_health, max_health)

func _emit_death(source):
	var source_name = NodeUtil.get_display_name(source)
	Log.warn("%s died (source=%s)" % [display_name, source_name])
	died.emit()
	set_enabled(false)
