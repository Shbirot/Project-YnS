extends HeroCharacter

@export var equipped_weapon : Weapon

func _ready() -> void:
	_move_config_from_weapon()
	move_speed = ConfigManager.get_value("hero.move_speed", move_speed)
	fire_interval = ConfigManager.get_value("hero.fire_interval", fire_interval)
	projectile_speed = ConfigManager.get_value("hero.projectile_speed", projectile_speed)
	max_health = ConfigManager.get_value("hero.max_health", max_health)
	super._ready()
	add_to_group("heroes")

func _move_config_from_weapon() -> void:
	if equipped_weapon:
		equipped_weapon.apply_to(self)
