extends RefCounted

class_name InteractionSystem

static func handle_collectible(collectible, actor) -> void:
	if not is_instance_valid(collectible) or not is_instance_valid(actor):
		return
	if collectible.has_method("apply_effect"):
		collectible.apply_effect(actor)

static func can_collect(collectible, actor) -> bool:
	return collectible.is_enabled and actor.is_in_group("heroes")
