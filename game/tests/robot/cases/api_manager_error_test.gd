extends "res://tests/robot/logic_test_case.gd"

const ApiManager = preload("res://scripts/core/api_manager.gd")

class PeerStub:
	extends RefCounted
	var messages := []

	func get_status():
		return StreamPeerTCP.STATUS_CONNECTED

	func get_available_bytes():
		return 0

	func get_utf8_string(_n):
		return ""

	func put_utf8_string(text):
		messages.append(text)

func get_name() -> String:
	return "ApiManagerError"

func run_case() -> void:
	var api = ApiManager.new()
	var peer = PeerStub.new()
	api._dispatch_command(peer, "unknown_command")
	assert_true(peer.messages.size() == 1, "Peer receives response for bad command")
	assert_true(peer.messages[0].begins_with("ERR"), "Unknown commands yield ERR responses")
	log_summary("ApiManager returned an ERR response when an unknown verb was dispatched.")
