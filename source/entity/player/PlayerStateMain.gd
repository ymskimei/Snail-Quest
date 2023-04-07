class_name PlayerStateMain
extends Node

var entity: Player

var input_up = 0
var input_down = 0
var input_left = 0
var input_right = 0

enum State {
	NULL,
	IDLE,
	MOVE,
	JUMP,
	FALL,
	TARG,
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
	apply_gravity(delta)
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
		MathHelper.slerp_look_at(entity, Vector3(target.x, entity.transform.origin.y, target.z), 1)
	elif !entity.is_on_wall() and entity.can_move:
		MathHelper.slerp_look_at(entity, entity.transform.origin + Vector3(entity.velocity.x, 0, entity.velocity.z), turn_speed)

func apply_movement(delta, no_sliding, angle):
	if entity.direction != Vector3.ZERO:
		entity.velocity.x = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).x
		entity.velocity.z = entity.velocity.move_toward(entity.direction * entity.speed, entity.acceleration * 8 * delta).z
	entity.velocity = entity.move_and_slide_with_snap(entity.velocity, entity.snap_vector, Vector3.UP, no_sliding, 4, angle)

func apply_gravity(delta):
	entity.velocity.y += -entity.gravity * delta
	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)

func dodge_roll():
	if Input.is_action_just_pressed("ui_up"):
		input_up += 1
		double_click()
		if input_up >= 2:
			return true
	if Input.is_action_just_pressed("ui_down"):
		input_down += 1
		double_click()
		if input_down >= 2:
			return true
	if Input.is_action_just_pressed("ui_left"):
		input_left += 1
		double_click()
		if input_left >= 2:
			return true
	if Input.is_action_just_pressed("ui_right"):
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
