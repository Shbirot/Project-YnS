extends MonsterCharacter

func _ready() -> void:
	move_speed = ConfigManager.get_value("monster.move_speed", move_speed)
	max_health = ConfigManager.get_value("monster.max_health", max_health)
	contact_damage = ConfigManager.get_value("monster.contact_damage", contact_damage)
	damage_interval = ConfigManager.get_value("monster.damage_interval", damage_interval)
	super._ready()
	add_to_group("enemies")
