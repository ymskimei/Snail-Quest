class_name PlayerStateMain
extends Node

var player: Player

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

func physics_process(delta: float) -> int:
	player.input = get_input_vector()
	player.direction = get_direction()
	if player.targeting:
		var target = player.current_target.transform.origin
		MathHelper.safe_look_at(player, Vector3(target.x, 0, target.z))
	elif !player.is_on_wall():
		#MathHelper.slerp_look_at(player, player, 3)
		MathHelper.safe_look_at(player, player.transform.origin + Vector3(player.velocity.x, 0, player.velocity.z))
	apply_movement(delta)
	apply_gravity(delta)
	update_snap_vector()
	return State.NULL

func process(_delta: float) -> int:
	return State.NULL

func get_input_vector():
	player.input.x = Input.get_action_raw_strength("ui_left") - Input.get_action_raw_strength("ui_right")
	player.input.z = Input.get_action_raw_strength("ui_up") - Input.get_action_raw_strength("ui_down")
	return player.input

func get_direction():
	player.direction = -player.input.rotated(Vector3.UP, player.player_cam.rotation.y).normalized()
	return player.direction

func apply_movement(delta):
	if player.direction != Vector3.ZERO:
		player.velocity.x = player.velocity.move_toward(player.direction * player.max_speed, player.acceleration * delta).x
		player.velocity.z = player.velocity.move_toward(player.direction * player.max_speed, player.acceleration * delta).z

func apply_gravity(delta):
	player.velocity.y += -player.gravity * delta
	player.velocity.y = clamp(player.velocity.y, -player.gravity, player.jump)

func update_snap_vector():
	player.snap_vector = -player.get_floor_normal() if player.is_on_floor() else Vector3.DOWN

func exit() -> void:
	pass
