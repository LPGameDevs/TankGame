extends Node2D

var input_prefix : String = "player1_"

var speed := 0.0
var teleporting := false

func _get_local_input() -> Dictionary:
	var input_vector = Input.get_vector(input_prefix + "left", input_prefix + "right", input_prefix + "up", input_prefix + "down")
	
	var input := {}
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	if Input.is_action_just_pressed(input_prefix + "bomb"):
		input["drop_bomb"] = true
	if Input.is_action_just_pressed(input_prefix + "teleport"):
		input["teleport"] = true
	
	return input


func _network_process(input: Dictionary) -> void:
	var input_vector = input.get("input_vector", Vector2.ZERO)
	if input_vector != Vector2.ZERO:
		if speed < 16.0:
			speed += 1.0
		position += input_vector * speed
	else:
		speed = 0.0
	


func _save_state() -> Dictionary:
	return {
		position = position,
		speed = speed,
		teleporting = teleporting,
	}

func _load_state(state: Dictionary) -> void:
	position = state['position']
	speed = state['speed']
	teleporting = state['teleporting']

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	if old_state.get('teleporting', false) or new_state.get('teleporting', false):
		return
	position = lerp(old_state['position'], new_state['position'], weight)
