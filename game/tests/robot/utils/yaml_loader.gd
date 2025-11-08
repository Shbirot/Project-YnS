extends RefCounted

class_name TestYamlLoader

static func load_yaml(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("YAML spec not found at %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Unable to open YAML spec at %s" % path)
		return {}
	var text := file.get_as_text()
	if text.strip_edges() == "":
		return {}
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("YAML spec %s is not a dictionary (JSON subset expected)" % path)
		return {}
	return parsed
