class_name PlayerStateMain
extends Node

var player: Player
var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO
var input_vector = Vector3.ZERO
var direction =	 Vector3.ZERO

export var max_speed = 7
export var acceleration = 100
export var gravity = -40
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
	direction = get_direction(input_vector)
	WorldMathHelper.safe_look_at(player.avatar, player.transform.origin + Vector3(velocity.x, 0, velocity.z))
	velocity = player.move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	apply_gravity(delta)
	update_snap_vector()
	return State.NULL

func apply_movement(direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z

func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_power)

func get_input_vector():
	input_vector.x = Input.get_action_raw_strength("ui_left") - Input.get_action_raw_strength("ui_right")
	input_vector.z = Input.get_action_raw_strength("ui_up") - Input.get_action_raw_strength("ui_down")
	return input_vector

func get_direction(input_vector):
	direction = -input_vector.rotated(Vector3.UP, player.player_cam.rotation.y).normalized()
	return direction

func update_snap_vector():
	snap_vector = -player.get_floor_normal() if player.is_on_floor() else Vector3.DOWN

func exit() -> void:
	pass
