class_name PlayerStateMain
extends Node

var entity: Player

var input_up = 0
var input_down = 0
var input_left = 0
var input_right = 0

var shell_jumped : bool
var previous_swing : bool
var action_combat_held : bool

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

func physics_process(delta: float) -> int:
	entity.input = get_joy_input()
	entity.direction = get_direction()
	apply_aim_cursor()
	if entity.is_on_floor():
		shell_jumped = false
	return State.NULL

func get_joy_input():
	entity.input.x = Input.get_action_strength("joy_left") - Input.get_action_strength("joy_right")
	entity.input.z = Input.get_action_strength("joy_up") - Input.get_action_strength("joy_down")
	return entity.input.normalized()

func get_direction():
	entity.direction = -entity.input.rotated(Vector3.UP, entity.player_cam.rotation.y)
	return entity.direction

func apply_facing(turn_speed):
	if entity.targeting:
		if is_instance_valid(entity.target) and entity.target_found:
			var target = entity.target.transform.origin
			MathHelper.slerp_look_at(entity, Vector3(target.x, entity.transform.origin.y, target.z), 0.2)
	elif !entity.is_on_wall() and entity.can_move:
		if entity.velocity != Vector3.ZERO:
			var look_direction = atan2(-entity.velocity.x, -entity.velocity.z)
			entity.rotation.y = lerp_angle(entity.rotation.y, look_direction, 0.2)
		if entity.ray_down.is_colliding() and entity.is_on_floor():
			var normal = entity.ray_down.get_collision_normal()
			var tform = MathHelper.apply_surface_align(entity.global_transform, normal)
			entity.global_transform = entity.global_transform.interpolate_with(tform, 0.3)
	elif entity.cursor_activated:
		MathHelper.slerp_look_at(entity, Vector3(GlobalManager.aim_cursor.global_translation.x, entity.transform.origin.y, GlobalManager.aim_cursor.global_translation.z), 0.3)
		pass

func apply_movement(delta, no_sliding, angle):
	if entity.can_move:
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
		if is_instance_valid(entity.get_parent().get_node("AimCursor")):
			entity.get_parent().get_node("AimCursor").queue_free()
			entity.cursor_activated = false
		else:
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
