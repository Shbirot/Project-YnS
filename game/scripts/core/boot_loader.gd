extends Node

const CONTROLLER_PATH := "/root/GameController"
const DISABLE_ENV := "NIGHTFALL_DISABLE_BOOT"

func _ready() -> void:
	call_deferred("_bootstrap")

func _bootstrap() -> void:
	if OS.has_environment(DISABLE_ENV) and OS.get_environment(DISABLE_ENV) != "":
		return
	var controller = get_node_or_null(CONTROLLER_PATH)
	if controller == null:
		push_warning("GameController not found; cannot boot.")
		return
	# GameController now initializes itself in _ready(), so initialization is already complete
	# Main scene is loaded automatically via project.godot run/main_scene setting
	# This function is now just a hook for future post-initialization logic
	controller.initialize()  # Idempotent, safe to call
