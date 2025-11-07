extends HeroCharacter

signal player_died

var coins := 0

func _ready() -> void:
	move_speed = ConfigManager.get_value("hero.move_speed", move_speed)
	fire_interval = ConfigManager.get_value("hero.fire_interval", fire_interval)
	projectile_speed = ConfigManager.get_value("hero.projectile_speed", projectile_speed)
	max_health = ConfigManager.get_value("hero.max_health", max_health)
	super._ready()
	add_to_group("heroes")

func add_currency(amount: int) -> void:
	coins += amount
	Log.debug("Hero coins=%d" % coins)

func get_snapshot_data() -> Dictionary:
	return {
		"health": _current_health,
	}

func apply_snapshot_data(state: Dictionary) -> void:
	if state.has("health"):
		_current_health = clamp(state["health"], 0, max_health)
		health_changed.emit(_current_health, max_health)

func _emit_death(source):
	super._emit_death(source)
	player_died.emit()
