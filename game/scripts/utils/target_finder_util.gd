extends RefCounted
class_name TargetFinderUtil

static func get_closest_target_in_group(from_position: Vector2, group: String, get_tree: Callable) -> Node2D:
	var nodes = get_tree.call().get_nodes_in_group(group)
	var closest_node = null
	var closest_distance_sq = INF
	for node in nodes:
		if not is_instance_valid(node) or not node is Node2D or not node.visible:
			continue
		var distance_sq = from_position.distance_squared_to(node.global_position)
		if distance_sq < closest_distance_sq:
			closest_distance_sq = distance_sq
			closest_node = node
	return closest_node
