class_name PlayerStateMain
extends Node

var entity: Player

enum State {
	NULL,
	IDLE,
	MOVE,
	JUMP,
	FALL,
	HIDE,
	ROLL
}

func enter() -> void:
	pass

func input(_event: InputEvent) -> int:
	return State.NULL

func physics_process(delta: float) -> int:
	entity.input = get_input_vector()
	entity.direction = get_direction()
	apply_movement(delta)
	apply_gravity(delta)
	entity.velocity = entity.move_and_slide_with_snap(entity.velocity, entity.snap_vector, Vector3.UP, true)
	return State.NULL

func process(_delta: float) -> int:
	return State.NULL

func get_input_vector():
	if entity.can_move:
		entity.input.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
		entity.input.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	else:
		entity.input.x = 0
		entity.input.z = 0
	return entity.input

func get_direction():
	entity.direction = -entity.input.rotated(Vector3.UP, entity.player_cam.rotation.y)
	return entity.direction

func apply_facing(turn_speed):
	if entity.targeting:
		var target = entity.target.transform.origin
		MathHelper.safe_look_at(entity, Vector3(target.x, 0, target.z))
	elif !entity.is_on_wall() and entity.can_move:
		MathHelper.slerp_look_at(entity, entity.transform.origin + Vector3(entity.velocity.x, 0, entity.velocity.z), turn_speed)

func apply_movement(delta):
	if entity.direction != Vector3.ZERO:
		entity.velocity.x = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).x
		entity.velocity.z = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).z

func apply_gravity(delta):
	entity.velocity.y += -entity.gravity * delta
	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)

func exit() -> void:
	pass
