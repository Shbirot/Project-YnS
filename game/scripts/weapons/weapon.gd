extends Resource
class_name Weapon

const WeaponAmmunition = preload("res://scripts/weapons/ammunition_base.gd")

@export var weapon_name := "Prototype"
@export var description := ""
@export var firing_rate := 0.7
@export var projectile_scene : PackedScene
@export var ammunition : WeaponAmmunition
@export var projectile_speed_override := -1.0
@export var damage_override := -1
@export var damage_type := "physical"

func apply_to(hero) -> void:
	if hero == null:
		return
	if hero.has_method("set_fire_interval_value"):
		hero.set_fire_interval_value(firing_rate)
	else:
		hero.fire_interval = firing_rate
	if projectile_scene:
		hero.projectile_scene = projectile_scene
	if projectile_speed_override > 0:
		hero.projectile_speed = projectile_speed_override
	if damage_override > 0:
		hero.base_damage = damage_override
	if ammunition and hero.has_method("set_ammunition"):
		hero.set_ammunition(ammunition)
	if hero.has_method("set_damage_type"):
		hero.set_damage_type(damage_type)
