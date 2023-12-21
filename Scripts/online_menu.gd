extends Control

func _on_local_button_pressed():
	SignalManager.on_local_game_requested.emit();

func _on_online_button_pressed():
	SignalManager.on_server_game_requested.emit();
