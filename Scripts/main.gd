extends Node2D

@onready var online_menu = $CanvasLayer/OnlineMenu
@onready var server_menu = $CanvasLayer/ServerMenu

func _ready() -> void:
	SignalManager.on_set_client_authority.connect(self._set_client_authority);
	SignalManager.on_local_game_requested.connect(self._local_game_requested);
	SignalManager.on_server_game_requested.connect(self._server_game_requested);
	
	$ServerPlayer.set_multiplayer_authority(1)

func _local_game_requested() -> void :
	$ServerPlayer.input_prefix = "player2_"
	online_menu.visible = false;

func _server_game_requested() -> void :
	online_menu.visible = false;
	server_menu.visible = true;

func _set_client_authority(peer_id: int) -> void :
	print('set auth ' + str(peer_id))
	$ClientPlayer.set_multiplayer_authority(peer_id);

func _on_reset_button_pressed():
	SignalManager.on_reset_game.emit();
	get_tree().reload_current_scene()
