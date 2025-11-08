extends Node

const DEFAULT_PATH := "res://config/data/objects/catalog.json"

const HeroFactory = preload("res://scripts/factories/hero_factory.gd")
const MonsterFactory = preload("res://scripts/factories/monster_factory.gd")
const ProjectileFactory = preload("res://scripts/factories/projectile_factory.gd")
const BaseObjectFactory = preload("res://scripts/factories/base_object_factory.gd")

var _catalog : Dictionary = {}
var _factories := {
	"hero": HeroFactory.new(),
	"monster": MonsterFactory.new(),
	"character": MonsterFactory.new(),
	"projectile": ProjectileFactory.new(),
	"visual": BaseObjectFactory.new(),
	"object": BaseObjectFactory.new(),
	"weapon": BaseObjectFactory.new(),
}

func _ready() -> void:
	load_catalog()

func load_catalog(path: String = DEFAULT_PATH) -> void:
	_catalog.clear()
	if not FileAccess.file_exists(path):
		push_warning("Object catalog not found at %s" % path)
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Unable to open catalog file %s" % path)
		return
	var text := file.get_as_text()
	var payload = JSON.parse_string(text)
	if typeof(payload) == TYPE_DICTIONARY:
		_catalog = payload
	else:
		push_warning("Catalog file %s is not a dictionary" % path)

func create(type_name: String, object_id: String) -> Node:
	var bucket: Dictionary = _catalog.get(type_name, {})
	var spec: Dictionary = bucket.get(object_id)
	if spec == null:
		push_warning("Object %s/%s not found in catalog" % [type_name, object_id])
		return null
	var factory = _factories.get(type_name, _factories.get("visual"))
	if factory == null:
		push_warning("No factory registered for type %s" % type_name)
		return null
	return factory.create(spec)

func create_hero(object_id: String) -> Node:
	return create("hero", object_id)

func create_monster(object_id: String) -> Node:
	return create("monster", object_id)

func create_projectile(object_id: String) -> Node:
	return create("projectile", object_id)

func list_entries(type_name: String) -> Array:
	var bucket: Dictionary = _catalog.get(type_name, {})
	var items: Array = bucket.values()
	items.sort_custom(Callable(self, "_sort_by_name"))
	return items

func get_spec(type_name: String, object_id: String) -> Dictionary:
	var bucket: Dictionary = _catalog.get(type_name, {})
	return bucket.get(object_id, {})

func _sort_by_name(a: Dictionary, b: Dictionary) -> bool:
	return a.get("name", "") < b.get("name", "")
