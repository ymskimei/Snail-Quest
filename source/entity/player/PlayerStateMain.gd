class_name PlayerStateMain
extends Node

var entity: Player

var input_up = 0
var input_down = 0
var input_left = 0
var input_right = 0

var shell_jumped : bool

enum State {
	NULL,
	IDLE,
	MOVE,
	JUMP,
	FALL,
	HIDE,
	DODG
}

func enter() -> void:
	pass

func input(_event: InputEvent) -> int:
	return State.NULL

func physics_process(delta: float) -> int:
	entity.input = get_input_vector()
	entity.direction = get_direction()
	if Input.is_action_pressed("action_combat"):
		entity.can_move = false
	else:
		entity.can_move = true
	if entity.is_on_floor():
		shell_jumped = false
	return State.NULL

func align_to_surface(tform, new_up):
	tform.basis.y = new_up
	tform.basis.x = -tform.basis.z.cross(new_up)
	tform.basis = tform.basis.orthonormalized()
	return tform

func process(_delta: float) -> int:
	return State.NULL

func get_input_vector():
	if entity.can_move:
		entity.input.x = Input.get_action_strength("joy_left") - Input.get_action_strength("joy_right")
		entity.input.z = Input.get_action_strength("joy_up") - Input.get_action_strength("joy_down")
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
		MathHelper.slerp_look_at(entity, Vector3(target.x, entity.transform.origin.y, target.z), 1)
	elif !entity.is_on_wall() and entity.can_move:
		if entity.velocity != Vector3.ZERO:
			var look_direction = atan2(-entity.velocity.x, -entity.velocity.z)
			entity.rotation.y = lerp_angle(entity.rotation.y, look_direction, 0.2)
		if entity.ray_down.is_colliding() and entity.is_on_floor():
			var normal = entity.ray_down.get_collision_normal()
			var tform = align_to_surface(entity.global_transform, normal)
			entity.global_transform = entity.global_transform.interpolate_with(tform, 0.3)

func apply_movement(delta, no_sliding, angle):
	if entity.direction != Vector3.ZERO:
		entity.velocity.x = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).x
		entity.velocity.z = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).z
	entity.velocity = entity.move_and_slide_with_snap(entity.velocity, entity.snap_vector, Vector3.UP, no_sliding, 4, angle)

func apply_gravity(delta):
	entity.velocity.y += -entity.gravity * delta
	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)

func dodge_roll():
	if entity.can_move:
		if Input.is_action_just_pressed("joy_up"):
			input_up += 1
			double_click()
			if input_up >= 2:
				return true
		if Input.is_action_just_pressed("joy_down"):
			input_down += 1
			double_click()
			if input_down >= 2:
				return true
		if Input.is_action_just_pressed("joy_left"):
			input_left += 1
			double_click()
			if input_left >= 2:
				return true
		if Input.is_action_just_pressed("joy_right"):
			input_right += 1
			double_click()
			if input_right >= 2:
				return true

func double_click():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.35)
	timer.connect("timeout", self, "on_input_timer")
	add_child(timer)
	timer.start()

func on_input_timer():
	input_up = 0
	input_down = 0
	input_left = 0
	input_right = 0

func exit() -> void:
	pass
