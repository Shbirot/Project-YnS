extends RefCounted
class_name NodeUtil

static func get_display_name(node) -> String:
	if is_instance_valid(node):
		if "display_name" in node and node.display_name != "":
			return node.display_name
		if "name" in node and node.name != "":
			return node.name
		return str(node.get_instance_id())
	return "<unknown>"
