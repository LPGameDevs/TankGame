extends Node

signal on_server_game_requested;
signal on_local_game_requested;

signal on_server_create_requested(port: int);
signal on_client_join_requested(host: String, port: int);

signal on_reset_game;

signal on_set_client_authority(peer_id: int);
