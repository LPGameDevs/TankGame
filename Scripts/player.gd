extends Node2D

@export var input_prefix : String = "player1_"

#var speed := 0.0
#var teleporting := false

func _get_local_input() -> Dictionary:
	var input_vector = Input.get_vector(input_prefix + "left", input_prefix + "right", input_prefix + "up", input_prefix + "down")
	
	var input := {}
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	
	return input


func _network_process(input: Dictionary) -> void:
	position += input.get("input_vector", Vector2.ZERO) * 8

func _save_state() -> Dictionary:
	return {
		position = position,
	}

func _load_state(state: Dictionary) -> void:
	position = state['position']

