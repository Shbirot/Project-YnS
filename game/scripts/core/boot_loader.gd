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
	controller.initialize()
	controller.start_main_scene()
