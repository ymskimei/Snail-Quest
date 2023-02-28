class_name PlayerStateMain
extends Node

var player: Player
var input_vector = Vector3.ZERO
var player_direction = Vector3.ZERO

export var max_speed = 7
export var acceleration = 100
export var gravity = -50
export var jump_power = 15

enum State {
	NULL,
	IDLE,
	MOVE,
	JUMP,
	FALL
}

func enter() -> void:
	pass

func input(_event: InputEvent) -> int:
	return State.NULL

func process(_delta: float) -> int:
	return State.NULL

func physics_process(delta: float) -> int:
	input_vector = get_input_vector()
	player_direction = get_direction()
	apply_movement(player_direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	return State.NULL

func apply_movement(direction, delta):
	if direction != Vector3.ZERO:
		player.velocity.x = player.velocity.move_toward(direction * max_speed, acceleration * delta).x
		player.velocity.z = player.velocity.move_toward(direction * max_speed, acceleration * delta).z

func apply_gravity(delta):
	player.velocity.y += gravity * delta
	player.velocity.y = clamp(player.velocity.y, gravity, jump_power)

func get_input_vector():
	input_vector.x = Input.get_action_raw_strength("ui_left") - Input.get_action_raw_strength("ui_right")
	input_vector.z = Input.get_action_raw_strength("ui_up") - Input.get_action_raw_strength("ui_down")
	return input_vector

func get_direction():
	player_direction = -input_vector.rotated(Vector3.UP, player.player_cam.rotation.y).normalized()
	return player_direction

func update_snap_vector():
	player.snap_vector = -player.get_floor_normal() if player.is_on_floor() else Vector3.DOWN

func exit() -> void:
	pass
