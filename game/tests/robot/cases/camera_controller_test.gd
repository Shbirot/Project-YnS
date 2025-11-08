extends "res://tests/robot/logic_test_case.gd"

const CameraController = preload("res://scripts/core/camera_controller.gd")

func get_name() -> String:
	return "CameraController"

func run_case() -> void:
	var camera = CameraController.new()
	var target = Node2D.new()
	camera.set_target(target)
	camera.world_bounds = Rect2(-100, -100, 200, 200)

	test_movement(camera, target)
	test_clamping(camera, target)

	camera.free()
	target.free()
	log_summary("CameraController correctly follows its target and clamps to world bounds.")

func test_movement(camera, target):
	target.global_position = Vector2(50, 50)
	camera._physics_process(1.0)
	assert_vector_almost_equal(camera.global_position, Vector2(50, 50), 0.1, "Camera moves towards target")

func test_clamping(camera, target):
	target.global_position = Vector2(150, 150)
	camera._physics_process(1.0)
	assert_vector_almost_equal(camera.global_position, Vector2(100, 100), 0.1, "Camera clamps to world bounds")
