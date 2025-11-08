extends Node

const CONTROLLER_PATH := "/root/GameController"

func _ready() -> void:
	call_deferred("_bootstrap")

func _bootstrap() -> void:
	var controller = get_node_or_null(CONTROLLER_PATH)
	if controller == null:
		push_warning("GameController not found; cannot boot.")
		return
	controller.initialize()
	controller.start_main_scene()
