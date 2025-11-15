extends RefCounted
class_name EnemyArchetypeRegistry

static func load_archetypes(dir_path: String) -> Dictionary:
	var registry: Dictionary = {}
	var dir = DirAccess.open(dir_path)
	if dir == null:
		push_warning("EnemyArchetypeRegistry: directory %s not found" % dir_path)
		return registry
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if dir.current_is_dir() or not file.ends_with(".tres"):
			continue
		var path = "%s/%s" % [dir_path, file]
		var resource = load(path)
		if resource is EnemyArchetype and resource.id != "":
			registry[resource.id] = resource
	dir.list_dir_end()
	return registry
