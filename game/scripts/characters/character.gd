extends MovableGameObject
class_name Character


signal health_changed(current, max)
signal died

@export var max_health := 100
@export var base_damage := 10
@export var team := "neutral"

var _current_health := 0

func _ready() -> void:
	super._ready()
	_current_health = max_health
	health_changed.emit(_current_health, max_health)

func apply_damage(amount: int, source = null) -> void:
	if amount <= 0 or not is_enabled:
		return
	_current_health = max(_current_health - amount, 0)
	health_changed.emit(_current_health, max_health)
	var source_name = source.display_name if source and "display_name" in source else "<unknown>"
	Log.debug("%s took %d damage (hp=%d) source=%s" % [display_name, amount, _current_health, source_name])
	if _current_health <= 0:
		_emit_death(source)

func heal(amount: int) -> void:
	_current_health = clamp(_current_health + amount, 0, max_health)
	health_changed.emit(_current_health, max_health)

func _emit_death(source):
	var source_name = source.display_name if source and "display_name" in source else "<unknown>"
	Log.warn("%s died (source=%s)" % [display_name, source_name])
	died.emit()
	set_enabled(false)
