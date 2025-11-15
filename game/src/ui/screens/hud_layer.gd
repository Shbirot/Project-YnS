extends CanvasLayer

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

@onready var health_value: Label = %HealthValue
@onready var level_value: Label = %LevelValue
@onready var xp_bar: ProgressBar = %XPBar
@onready var version_label: Label = %VersionLabel
var _event_bus: Node
var _level_manager: Node

func _ready() -> void:
	_bind_event_bus()
	_bind_level_manager()
	_update_version_label()

func _bind_event_bus() -> void:
	_event_bus = SingletonUtil.get_event_bus()
	if _event_bus:
		if not _event_bus.is_connected("hero_health_changed", Callable(self, "_on_hero_health_changed")):
			_event_bus.connect("hero_health_changed", Callable(self, "_on_hero_health_changed"))
		if not _event_bus.is_connected("hero_died", Callable(self, "_on_hero_died")):
			_event_bus.connect("hero_died", Callable(self, "_on_hero_died"))

func _bind_level_manager() -> void:
	_level_manager = SingletonUtil.get_level_manager()
	if _level_manager:
		if not _level_manager.is_connected("xp_changed", Callable(self, "_on_xp_changed")):
			_level_manager.connect("xp_changed", Callable(self, "_on_xp_changed"))
		if not _level_manager.is_connected("leveled_up", Callable(self, "_on_leveled_up")):
			_level_manager.connect("leveled_up", Callable(self, "_on_leveled_up"))
		if _level_manager.has_method("emit_state"):
			_level_manager.emit_state()

func _on_hero_health_changed(current_health: float, max_health: float) -> void:
	if health_value:
		health_value.text = "%d / %d" % [ceil(current_health), ceil(max_health)]

func _on_xp_changed(current_xp: int, required_xp: int, level: int) -> void:
	if xp_bar:
		xp_bar.max_value = max(required_xp, 1)
		xp_bar.value = current_xp
	if level_value:
		level_value.text = "Lv %d" % level

func _on_leveled_up(level: int) -> void:
	# Placeholder for upgrade UI.
	if level_value:
		level_value.text = "Lv %d" % level

func _on_hero_died(_hero: Node) -> void:
	if health_value:
		health_value.text = "DEFEATED"

func _update_version_label() -> void:
	if version_label == null:
		return
	var version_info = SingletonUtil.get_version_info()
	if version_info:
		version_label.text = "v%s" % version_info.version_string
	else:
		version_label.text = "vDEV"
