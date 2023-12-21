extends Node2D

const DummyNetworkAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

const LOG_FILE_DIRECTORY: String = 'user://detailed_logs';
var logging_enabled: bool = false;

func _ready() -> void:
	multiplayer.peer_connected.connect(self._peer_connected)
	multiplayer.peer_disconnected.connect(self._peer_disconnected)
	multiplayer.connected_to_server.connect(self._server_connected)
	multiplayer.server_disconnected.connect(self._server_disconnected)
	
	SyncManager.connect("sync_started", self._SyncManager_sync_started)
	SyncManager.connect("sync_stopped", self._SyncManager_sync_stopped)
	SyncManager.connect("sync_lost", self._SyncManager_sync_lost)
	SyncManager.connect("sync_regained", self._SyncManager_sync_regained)
	SyncManager.connect("sync_error", self._SyncManager_sync_error)
	
	SignalManager.on_local_game_requested.connect(self._local_game_requested);
	SignalManager.on_server_game_requested.connect(self._server_game_requested);
	SignalManager.on_server_create_requested.connect(self._server_create_requested);
	SignalManager.on_client_join_requested.connect(self._client_join_requested);
	SignalManager.on_reset_game.connect(self._reset_game);

	SyncManager.spectating = false;

## User has requested to play a local game.
func _local_game_requested() -> void :
	SyncManager.network_adaptor = DummyNetworkAdaptor.new()
	SyncManager.start()

## User has requested to play an online game.
func _server_game_requested() -> void :
	SyncManager.reset_network_adaptor()

## User has requested to create a new server.
func _server_create_requested(port: int) -> void :
	SyncManager.spectating = false
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer

## User has requested to join an existing server.
func _client_join_requested(host: String, port: int) -> void :
	SyncManager.spectating = false
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(host, port);
	multiplayer.multiplayer_peer = peer

## Button press to reset game requested by user.
func _reset_game() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()

func _peer_connected(peer_id: int):
	print(str(peer_id) + " connected");
	if not multiplayer.is_server() and peer_id != 1:
		register_player.rpc_id(peer_id, {spectator = SyncManager.spectating})

	
@rpc("any_peer")
func register_player(options: Dictionary = {}) -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	SyncManager.add_peer(peer_id, options)
	var peer = SyncManager.peers[peer_id]

	if not peer.spectator:
		SignalManager.on_set_client_authority.emit(peer_id);
		
		if multiplayer.is_server():
			multiplayer.multiplayer_peer.refuse_new_connections = true

			# Give a little time to get ping data.
			await get_tree().create_timer(2.0).timeout
			SyncManager.start()


func _peer_disconnected(peer_id: int):
	print(str(peer_id) + " disconnected");
	SyncManager.remove_peer(peer_id)
	pass;

func _server_connected():
	print("server connected");
	if not SyncManager.spectating:
		SignalManager.on_set_client_authority.emit(multiplayer.get_unique_id());

	SyncManager.add_peer(1)
	# Tell server about ourselves.
	register_player.rpc_id(1, {spectator = SyncManager.spectating})

	pass;
	
func _server_disconnected():
	_peer_disconnected(1);
	print("server disconnected");
	pass

func _SyncManager_sync_started():
	print("syncManager started");

	#if logging_enabled and not SyncReplay.active:
	if logging_enabled:
		if not DirAccess.dir_exists_absolute(LOG_FILE_DIRECTORY):
			DirAccess.make_dir_absolute(LOG_FILE_DIRECTORY)

		var datetime := Time.get_datetime_dict_from_system(true)
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
			datetime['year'],
			datetime['month'],
			datetime['day'],
			datetime['hour'],
			datetime['minute'],
			datetime['second'],
			multiplayer.get_unique_id(),
		]

		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)

func _SyncManager_sync_stopped():
	print("syncManager stopped");
	if logging_enabled:
		SyncManager.stop_logging()

	pass
	
func _SyncManager_sync_lost():
	print("syncManager lost");
	#sync_lost_label.visible = true
	pass
	
func _SyncManager_sync_regained():
	print("syncManager regained");
	#sync_lost_label.visible = false
	pass
	
func _SyncManager_sync_error(msg: String):
	print("syncManager sync error");
	print(msg);
	#message_label.text = "Fatal sync error: " + msg
	#sync_lost_label.visible = false

	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
	SyncManager.clear_peers()
