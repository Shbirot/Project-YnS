extends Node

## Data-driven registry for gameplay scenes/resources used by the prototype.
## Autoload name: GameCatalog

var _entries := {
	"hero": "res://src/features/player/hero.tscn",
	"default_enemy": "res://src/features/enemy/enemy_basic.tscn",
	"ranged_enemy": "res://src/features/enemy/ranged_enemy.tscn",
	"default_projectile": "res://src/features/projectiles/projectile_basic.tscn",
	"xp_orb": "res://src/features/items/xp_orb.tscn",
}

func get_scene_path(key: String) -> String:
	if key not in _entries:
		push_warning("GameCatalog: missing key %s" % key)
		return ""
	return _entries[key]

func instantiate(key: String) -> Node:
	var path := get_scene_path(key)
	if path == "":
		return null
	var packed := load(path)
	if packed == null:
		push_error("GameCatalog: failed to load %s" % path)
		return null
	return packed.instantiate()

func register_entry(key: String, path: String) -> void:
	_entries[key] = path

func has_entry(key: String) -> bool:
	return key in _entries
