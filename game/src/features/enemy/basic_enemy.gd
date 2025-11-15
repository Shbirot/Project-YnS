extends "res://src/features/enemy/monster.gd"


@export var damage := 5.0
@export var xp_orb_scene: PackedScene

@onready var damage_area: Area2D = $DamageArea

func _on_monster_ready() -> void:
	var cfg = SingletonUtil.get_game_config()
	damage = cfg.get_env_value("NF_ENEMY_DAMAGE", damage)
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_entered)

func _on_monster_died(_source: Node) -> void:
	_spawn_xp()

func _spawn_xp() -> void:
	if xp_orb_scene == null:
		return
	var orb := xp_orb_scene.instantiate()
	if orb == null:
		return
	call_deferred("_add_orb", orb)

func _add_orb(orb: Node) -> void:
	get_tree().current_scene.add_child(orb)
	orb.global_position = global_position

func _on_damage_area_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		var damage_system = SingletonUtil.get_damage_system()
		if damage_system:
			damage_system.apply_hero_damage(self, damage)
