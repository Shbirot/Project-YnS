extends Node

## WeaponRegistry - Preloads all weapons and ammo at boot
## Eliminates runtime disk I/O for weapon/ammo instantiation

const SingletonUtil = preload("res://src/shared/scripts/singleton_util.gd")

var _weapons: Dictionary = {}
var _ammo_scenes: Dictionary = {}

func _ready() -> void:
	_preload_weapons()
	_preload_ammo()
	var logger = SingletonUtil.get_logger()
	if logger:
		logger.info("WeaponRegistry initialized", {
			"weapons": _weapons.size(),
			"ammo_scenes": _ammo_scenes.size()
		})

func get_weapon(weapon_id: String):
	if _weapons.has(weapon_id):
		return _weapons[weapon_id].duplicate(true)
	push_warning("WeaponRegistry: weapon not found: " + weapon_id)
	return null

func get_ammo(ammo_id: String):
	if _ammo_scenes.has(ammo_id):
		return _ammo_scenes[ammo_id]
	push_warning("WeaponRegistry: ammo scene not found: " + ammo_id)
	return null

func has_weapon(weapon_id: String) -> bool:
	return _weapons.has(weapon_id)

func has_ammo(ammo_id: String) -> bool:
	return _ammo_scenes.has(ammo_id)

func _preload_weapons() -> void:
	var weapon_paths = [
		"res://src/features/weapons/basic_wand.tres",
		"res://src/features/weapons/environmental_aura_weapon.tres",
		"res://src/features/weapons/boss_beam_weapon.tres",
		"res://src/features/weapons/ranged_enemy_weapon.tres",
		"res://src/features/weapons/gladiator_blade_weapon.tres",
	]

	for path in weapon_paths:
		if not ResourceLoader.exists(path):
			continue
		var weapon = load(path)
		if weapon and weapon.has("id"):
			_weapons[weapon.id] = weapon

func _preload_ammo() -> void:
	# Scan for ammo scenes in projectiles directory
	var ammo_dir = "res://src/features/projectiles/"
	var dir = DirAccess.open(ammo_dir)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var full_path = ammo_dir + file_name
			var scene = load(full_path)
			if scene:
				var ammo_id = file_name.get_basename()
				_ammo_scenes[ammo_id] = scene
		file_name = dir.get_next()
	dir.list_dir_end()
