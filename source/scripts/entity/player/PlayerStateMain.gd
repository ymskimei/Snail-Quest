class_name PlayerStateMain
extends Node

var entity

var direction := Vector3.ZERO

var input_up = 0
var input_down = 0
var input_left = 0
var input_right = 0

var shell_jumped : bool
var previous_swing : bool
var action_combat_held : bool
var is_on_floor : bool

var timer = Timer.new()

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

func _ready():
	timer.set_one_shot(true)
	timer.set_wait_time(0.35)
	timer.connect("timeout", self, "on_input_timer")
	add_child(timer)
	return State.NULL

func input(_event: InputEvent) -> int:
	return State.NULL

func physics_process(_delta: float) -> int:
	apply_aim_cursor()
	if is_on_floor:
		shell_jumped = false
	return State.NULL

func integrate_forces(state) -> int:
	set_gravity_direction()
	return State.NULL

func set_gravity_direction():
	var climbing_normal = Vector3.ZERO
	var norm_avg = Vector3.ZERO
	var rays_colliding := 0
	for ray in entity.climbing_rays.get_children():
		var r : RayCast = ray
		if r.is_colliding():
			rays_colliding += 1
			norm_avg += r.get_collision_normal()
	if norm_avg:
		climbing_normal = norm_avg / rays_colliding
	else:
		climbing_normal = Vector3.UP
	if rays_colliding >= 1:
		is_on_floor = true
	else:
		is_on_floor = false
	entity.global_transform = MathHelper.apply_surface_align(entity.global_transform, climbing_normal)
	entity.add_central_force(25 * -climbing_normal)

func get_joy_input():
	var input = entity.input
	input.x = Input.get_action_strength("joy_left") - Input.get_action_strength("joy_right")
	input.z = Input.get_action_strength("joy_up") - Input.get_action_strength("joy_down")
	var input_length = input.length()
	if input_length > 1:
		input /= input_length
	return input
#
#func apply_facing():
#	if get_joy_input() != Vector3.ZERO:
#		entity.rotation.y = lerp_angle(entity.rotation.y, atan2(-entity.linear_velocity.x, -entity.linear_velocity.z), 1.0)

func apply_movement():
	if entity.is_active_player and entity.can_move:
		direction.x = -get_joy_input().rotated(Vector3.UP, entity.player_cam.rotation.y).x
		direction.z = -get_joy_input().rotated(Vector3.UP, entity.player_cam.rotation.y).z
		#direction = entity.transform.basis.xform(direction)
		#entity.set_linear_velocity(entity.speed * direction / 7)
		if direction != Vector3.ZERO:
			entity.linear_velocity.x = lerp(entity.linear_velocity.x, entity.speed * direction.x, 0.5)
			entity.linear_velocity.z = lerp(entity.linear_velocity.z, entity.speed * direction.z, 0.5)
			if entity.linear_velocity != Vector3.ZERO:
				entity.last_vel = entity.linear_velocity

func dodge_roll():
	if entity.is_active_player and entity.can_move:
		if Input.is_action_just_pressed("joy_up"):
			input_up += 1
			timer.start()
			if input_up >= 2:
				return true
		if Input.is_action_just_pressed("joy_down"):
			input_down += 1
			timer.start()
			if input_down >= 2:
				return true
		if Input.is_action_just_pressed("joy_left"):
			input_left += 1
			timer.start()
			if input_left >= 2:
				return true
		if Input.is_action_just_pressed("joy_right"):
			input_right += 1
			timer.start()
			if input_right >= 2:
				return true

func on_input_timer():
	input_up = 0
	input_down = 0
	input_left = 0
	input_right = 0
	if Input.is_action_pressed("action_combat"):
		action_combat_held = true
	else:
		action_combat_held = false

func apply_aim_cursor():
	if entity.targeting and entity.target_found or entity.cursor_activated:
		var cursor = entity.cursor.instance()
		if is_instance_valid(entity.get_parent().get_node_or_null("AimCursor")):
			entity.get_parent().get_node("AimCursor").queue_free()
			entity.cursor_activated = false
		else:
			cursor.set_name("AimCursor")
			entity.get_parent().add_child(cursor)
			entity.cursor_activated = true

func needle():
	var needle = entity.eye_point.get_node_or_null("Needle")
	if is_instance_valid(needle):
#		if Input.is_action_just_released("action_combat"):
#			if previous_swing:
#				entity.animator.play("PlayerSwingDefault")
#				needle.swing_left()
#				previous_swing = false
#			else:
#				entity.animator.play_backwards("PlayerSwingDefault")
#				needle.swing_right()
#				previous_swing = true
#		if entity.targeting:
#			needle.directionaaal_swing()
		if Input.is_action_just_pressed("action_combat"):
			entity.can_move = false
			entity.cursor_activated = true
		if Input.is_action_just_released("action_combat"):
			entity.can_move = true
			entity.cursor_activated = false
#			var last_pos = needle.global_transform
#			entity.eye_point.remove_child(needle)
#			entity.get_parent().add_child(needle)
#			var detatched_needle = entity.get_parent().get_node_or_null("Needle")
#			detatched_needle.global_transform = last_pos
#			#var throw_dir = target_position - player_position
#			var throw_dir = entity.transform.basis.xform(Vector3(0, 0, -1).normalized())
#			detatched_needle.throw(throw_dir)

func mallet():
	var mallet = entity.eye_point.get_node_or_null("Mallet")
	if is_instance_valid(mallet):
		if Input.is_action_just_pressed("action_combat"):
			timer.start()
			yield(timer, "timeout")
			if action_combat_held == true:
				entity.can_move = false
				entity.animator.play("PlayerSlamDefault")
				mallet.slam()
		elif Input.is_action_just_released("action_combat"):
			entity.can_move = true
			entity.animator.play("PlayerIdleDefault")
			mallet.end_slam()
		if Input.is_action_just_released("action_combat") and action_combat_held == false:
			if entity.animator.current_animation != "PlayerSwingDefault":
				print("true")
				if previous_swing:
					entity.animator.play_backwards("PlayerSwingDefault")
					mallet.swing_left()
					yield(entity.animator, "animation_finished")
					previous_swing = false
				else:
					entity.animator.play("PlayerSwingDefault")
					mallet.swing_right()
					yield(entity.animator, "animation_finished")
					previous_swing = true

func exit() -> void:
	pass
