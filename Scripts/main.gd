extends Node2D

func _ready() -> void:
	multiplayer.peer_connected.connect(self._on_peer_connected)

func _on_peer_connected(peer_id: int):
	SyncManager.add_peer(peer_id)
	
	$ServerPlayer.set_network_master(1)
	if get_tree().is_network_server():
		$ClientPlayer.set_network_master(peer_id)
	else:
		$ClientPlayer.set_network_master(get_tree().get_network_unique_id())
	
	if get_tree().is_network_server():
		SyncManager.start()
