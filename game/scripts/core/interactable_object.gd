extends VisualGameObject
class_name InteractableObject


signal interacted(actor)

@export var interactable := true
@export var prompt_text := "Interact"

func can_interact() -> bool:
	return interactable and is_enabled

func interact(actor) -> void:
	if can_interact():
		Log.info("%s interacted with %s" % [actor, display_name])
		interacted.emit(actor)
