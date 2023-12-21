extends Control

func _on_server_button_pressed():
	SignalManager.on_server_create_requested.emit(9999);
	self.visible = false;

func _on_client_button_pressed():
	SignalManager.on_client_join_requested.emit('127.0.0.1', 9999);
	self.visible = false;
