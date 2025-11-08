extends Node

class_name ApiManager

const PORT := 6969
const STATUS_CONNECTED := StreamPeerTCP.STATUS_CONNECTED
var _server := TCPServer.new()
var _clients = []
var _game_controller

func start(controller) -> void:
	_game_controller = controller
	var err = _server.listen(PORT)
	if err != OK:
		push_warning("API server failed to listen on port %d (err %d)" % [PORT, err])
		return
	set_process(true)
	print("[API] Listening on port %d" % PORT)

func stop() -> void:
	set_process(false)
	for client in _clients:
		client.disconnect_from_host()
	_clients.clear()
	_server.stop()

func _process(_delta: float) -> void:
	if _server.is_connection_available():
		var peer = _server.take_connection()
		peer.set_no_delay(true)
		_clients.append(peer)
	if _clients.is_empty():
		return
	for peer in _clients.duplicate():
		if not peer:
			_clients.erase(peer)
			continue
		if peer.get_status() != STATUS_CONNECTED:
			_clients.erase(peer)
			continue
		var available = peer.get_available_bytes()
		if available > 0:
			var payload = peer.get_utf8_string(available)
			_handle_payload(peer, payload)

func _handle_payload(peer, payload) -> void:
	var lines = payload.split("\n", false)
	for line in lines:
		var cmd = line.strip_edges()
		if cmd == "":
			continue
		_dispatch_command(peer, cmd)

func _dispatch_command(peer, command) -> void:
	if _game_controller == null:
		_reply(peer, "ERR: controller unavailable")
		return
	var tokens = command.split(" ", false, 1)
	var verb = tokens[0].to_lower()
	var arg = ""
	if tokens.size() > 1:
		arg = tokens[1]
	match verb:
		"pause":
			_game_controller.call_deferred("pause_game")
			_reply(peer, "OK: paused")
		"resume":
			_game_controller.call_deferred("resume_game")
			_reply(peer, "OK: resumed")
		"reset":
			_game_controller.call_deferred("reset_game")
			_reply(peer, "OK: resetting")
		"list_components":
			_game_controller.call_deferred("log_component_stats")
			_reply(peer, "OK: logging components")
		"show_window":
			_game_controller.call_deferred("show_window", arg)
			_reply(peer, "OK: showing %s" % arg)
		"hide_window":
			_game_controller.call_deferred("hide_window", arg)
			_reply(peer, "OK: hiding %s" % arg)
		_:
			_reply(peer, "ERR: unknown command '%s'" % command)

func _reply(peer, message) -> void:
	peer.put_utf8_string(message + "\n")
