extends "res://tests/robot/logic_test_case.gd"

const ApiManager = preload("res://scripts/core/api_manager.gd")

class ControllerStub:
	extends Node
	var paused := false
	var resumed := false
	var reset := false

	func pause_game():
		paused = true

	func resume_game():
		resumed = true

	func reset_game():
		reset = true

	func log_component_stats():
		pass

	func show_window(_name):
		pass

	func hide_window(_name):
		pass

class PeerStub:
	extends RefCounted
	var messages := []

	# Provide interface used by ApiManager
	func get_status():
		return StreamPeerTCP.STATUS_CONNECTED

	func get_available_bytes():
		return 0

	func get_utf8_string(_n):
		return ""

	func put_utf8_string(text):
		messages.append(text)

func get_name() -> String:
	return "ApiManager"

func run_case() -> void:
	var api = ApiManager.new()
	var controller = ControllerStub.new()
	var peer = PeerStub.new()
	api._game_controller = controller
	api._dispatch_command(peer, "pause")
	api._dispatch_command(peer, "resume")
	api._dispatch_command(peer, "reset")
	assert_true(controller.paused and controller.resumed and controller.reset, "Controller methods invoked")
	assert_true(len(peer.messages) >= 3, "Peer received responses")
	log_summary("Dispatched pause/resume/reset commands through ApiManager and verified controller callbacks plus peer acknowledgements.")
