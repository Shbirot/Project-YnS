extends RefCounted
class_name SceneTreeUtil

static func get_root() -> Node:
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		return loop.get_root()
	return null

static func get_autoload(node_name: String) -> Node:
	var root = get_root()
	if root:
		return root.get_node_or_null(node_name)
	return null

static func get_manager(manager_name: String) -> Node:
	var controller = get_autoload("GameController")
	if controller and controller.has_method("get_" + manager_name):
		return controller.call("get_" + manager_name)
	return null
