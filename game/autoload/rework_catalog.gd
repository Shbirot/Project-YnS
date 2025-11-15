extends Node

## Data-driven registry for gameplay scenes/resources used by the rework prototype.
## Autoload name: ReworkCatalog

var _entries := {
	"hero": "res://scenes/rework/hero.tscn",
	"default_enemy": "res://scenes/rework/enemy_basic.tscn",
	"default_projectile": "res://scenes/rework/projectile_basic.tscn",
	"xp_orb": "res://scenes/rework/xp_orb.tscn",
}

func get_scene_path(key: String) -> String:
	if key not in _entries:
		push_warning("ReworkCatalog: missing key %s" % key)
		return ""
	return _entries[key]

func instantiate(key: String) -> Node:
	var path := get_scene_path(key)
	if path == "":
		return null
	var packed := load(path)
	if packed == null:
		push_error("ReworkCatalog: failed to load %s" % path)
		return null
	return packed.instantiate()

func register_entry(key: String, path: String) -> void:
	_entries[key] = path

func has_entry(key: String) -> bool:
	return key in _entries
