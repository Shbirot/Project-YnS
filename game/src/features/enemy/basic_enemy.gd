extends "res://src/features/enemy/monster_base.gd"

@export var damage = 5.0
@onready var damage_area: Area2D = $DamageArea

func _on_monster_ready() -> void:
	var cfg = SingletonUtil.get_game_config()
	var base_damage = get_stat_value("attack", damage)
	damage = cfg.get_env_value("NF_ENEMY_DAMAGE", base_damage)
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_entered)
		damage_area.set_deferred("monitoring", false)
		damage_area.set_deferred("monitorable", false)

func _on_spawn_prepared() -> void:
	if damage_area:
		damage_area.set_deferred("monitoring", true)
		damage_area.set_deferred("monitorable", true)

func _on_recycled() -> void:
	if damage_area:
		damage_area.set_deferred("monitoring", false)
		damage_area.set_deferred("monitorable", false)

func _on_damage_area_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		var damage_system = SingletonUtil.get_damage_system()
		if damage_system:
			damage_system.apply_hero_damage(self, damage)
