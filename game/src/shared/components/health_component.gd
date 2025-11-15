extends Node
class_name HealthComponent

## Standalone health and damage management component
## Uses direct callbacks instead of signals for performance

# Replaced signals with direct callbacks to reduce overhead
# signal died(actor: Node)
# signal health_changed(actor: Node, current_hp: float, max_hp: float)

@export var base_max_hp := 10.0

var hp := 0.0
var is_alive := true

var _actor: Node
var _on_died_callback: Callable
var _on_health_changed_callback: Callable

func _ready() -> void:
	_actor = get_parent()
	hp = base_max_hp
	_notify_health_changed()

func set_callbacks(on_died: Callable, on_health_changed: Callable) -> void:
	_on_died_callback = on_died
	_on_health_changed_callback = on_health_changed

func apply_damage(amount: float, source: Node) -> void:
	if amount <= 0.0 or not is_alive:
		return

	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("Damage applied", {"amount": amount, "actor": _actor.name if _actor else "unknown"})

	hp = max(0.0, hp - amount)
	is_alive = hp > 0.0

	_notify_health_changed()

	if not is_alive and _on_died_callback.is_valid():
		_on_died_callback.call(_actor)

func heal(amount: float) -> void:
	if amount <= 0.0 or not is_alive:
		return

	if OS.has_environment("NF_DEBUG") and OS.get_environment("NF_DEBUG") == "1":
		DebugUtils.debug_log("Healing applied", {"amount": amount, "actor": _actor.name if _actor else "unknown"})

	hp = clamp(hp + amount, 0.0, base_max_hp)
	_notify_health_changed()

func revive(full_hp: bool = true) -> void:
	hp = base_max_hp if full_hp else max(1.0, hp)
	is_alive = true
	_notify_health_changed()

func set_max_hp(new_max: float) -> void:
	base_max_hp = new_max
	if hp > base_max_hp:
		hp = base_max_hp
	_notify_health_changed()

func get_hp() -> float:
	return hp

func get_max_hp() -> float:
	return base_max_hp

func _notify_health_changed() -> void:
	if _on_health_changed_callback.is_valid():
		_on_health_changed_callback.call(_actor, hp, base_max_hp)
