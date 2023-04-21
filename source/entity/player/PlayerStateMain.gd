class_name PlayerStateMain
extends Node

var entity: Player

var input_up = 0
var input_down = 0
var input_left = 0
var input_right = 0

var shell_jumped : bool
var previous_swing : bool

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
	entity.input = get_joy_input()
	entity.direction = get_direction()
	if entity.ray_down.is_colliding():
		shell_jumped = false
	return State.NULL

func integrate_forces(state) -> int:
	return State.NULL

func get_joy_input():
	if entity.can_move:
		entity.input.x = Input.get_action_strength("joy_left") - Input.get_action_strength("joy_right")
		entity.input.z = Input.get_action_strength("joy_up") - Input.get_action_strength("joy_down")
		#entity.input = entity.transform.basis.xform(entity.input)
	else:
		entity.input.x = 0
		entity.input.z = 0
	return entity.input

func get_direction():
	entity.direction = -entity.input.rotated(Vector3.UP, entity.player_cam.rotation.y)
	return entity.direction

#func apply_facing(turn_speed):
#	if entity.targeting:
#		var target = entity.target.transform.origin
#		MathHelper.slerp_look_at(entity, Vector3(target.x, entity.transform.origin.y, target.z), 1)
#	elif entity.can_move:
#		if entity.velocity != Vector3.ZERO:
#			var look_direction = atan2(-entity.velocity.x, -entity.velocity.z)
#			entity.rotation.y = lerp_angle(entity.rotation.y, look_direction, 0.2)
#		if entity.ray_down.is_colliding():
#			var normal = entity.ray_down.get_collision_normal()
#			var tform = apply_surface_align(entity.global_transform, normal)
#			entity.global_transform = entity.global_transform.interpolate_with(tform, 0.3)
#
#func apply_surface_align(tform, new_up):
#	tform.basis.y = new_up
#	tform.basis.x = -tform.basis.z.cross(new_up)
#	tform.basis = tform.basis.orthonormalized()
#	return tform

func apply_movement():
	var x = -entity.input.rotated(Vector3.UP, entity.player_cam.rotation.y).x * 7
	var y = entity.get_linear_velocity().y
	var z = -entity.input.rotated(Vector3.UP, entity.player_cam.rotation.y).z * 7
	entity.set_linear_velocity(Vector3(x, y, z))

#func apply_facing(direction, delta) -> void:
#	var left_axis := -lo
	

#func apply_movement(delta, no_sliding, angle):
#	if entity.direction != Vector3.ZERO:
#		entity.velocity.x = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).x
#		entity.velocity.z = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).z
	#entity.velocity = entity.move_and_slide_with_snap(entity.velocity, entity.snap_vector, Vector3.UP, no_sliding, 4, angle)
#	var impulse = (entity.velocity - entity.linear_velocity) * entity.mass
#	entity.apply_impulse(Vector3.ZERO, Vector3(impulse.x, 0, impulse.z))

#func apply_gravity(delta):
#	entity.velocity.y += -entity.gravity * delta
#	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)

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

func needle_swing():
	var needle = entity.eye_point.get_node_or_null("Needle")
	if is_instance_valid(needle):
		if Input.is_action_just_released("action_combat"):
			if previous_swing:
				entity.animator.play("PlayerSwingDefault")
				needle.swing_left()
				previous_swing = false
			else:
				entity.animator.play_backwards("PlayerSwingDefault")
				needle.swing_right()
				previous_swing = true

func needle_aiming():
	var needle = entity.eye_point.get_node_or_null("Needle")
	if is_instance_valid(needle):
		needle.directional_swing()

func mallet_slam():
	var mallet = entity.eye_point.get_node_or_null("Mallet")
	if is_instance_valid(mallet):
		if Input.is_action_pressed("action_combat"):
			entity.can_move = false
			entity.animator.play("PlayerSlamDefault")
			mallet.slam()
		else:
			mallet.end_slam()
			entity.can_move = true

func exit() -> void:
	pass
