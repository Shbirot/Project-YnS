extends SceneTree

@export var scene_path = "res://src/levels/main.tscn"
var _auto_exit_seconds = 0
var _elapsed = 0.0

func _initialize() -> void:
	if OS.has_environment("MANUAL_LAUNCHER_AUTO_EXIT"):
		_auto_exit_seconds = int(OS.get_environment("MANUAL_LAUNCHER_AUTO_EXIT"))
	call_deferred("_launch")

func _launch() -> void:
	var packed = load(scene_path)
	if packed == null:
		push_error("[manual_launcher] Unable to load scene %s" % scene_path)
		quit()
		return
	print("[manual_launcher] Launching %s. Close the window to stop the simulation." % scene_path)
	change_scene_to_packed(packed)

func _process(delta: float) -> bool:
	if _auto_exit_seconds <= 0:
		return false
	_elapsed += delta
	if _elapsed >= _auto_exit_seconds:
		print("[manual_launcher] Auto exit reached after %d seconds." % _auto_exit_seconds)
		quit()
	return true
