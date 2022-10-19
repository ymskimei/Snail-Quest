extends KinematicBody

export var player_name = "Sheldon"

export var player_gravity = -40
export var player_jump_power = 12
export var player_maximum_speed = 9
export var player_acceleration = 70
export var player_friction = 60
export var player_airborne_friction = 15
export var player_rotation_speed = 30

var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO

var world_variables = preload ("res://source/WorldVariables.gd")
onready var player_avatar = $PlayerAvatar
onready var player_hitbox = $PlayerHitbox
onready var player_cam_arm = $CameraArm

export var cam_smoothness = 20
export var sensitivity_mouse = 2
export var sensitivity_stick = 2

var cam_velocity: Vector2
var cam_input : Vector2
var controller_detected = false

func _ready():
	world_variables.register_player(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_input = event.relative
		controller_detected = false
	elif event is InputEventJoypadMotion:
		controller_detected = true

func _physics_process(delta):
	var axis_vector = Vector2.ZERO
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	apply_gravity(delta)
	update_snap_vector()
	apply_jump()
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	if controller_detected:
		cam_input = axis_vector
		cam_velocity = cam_velocity.linear_interpolate(cam_input * sensitivity_stick * 1.5, delta * cam_smoothness / 2.5)
	else: cam_velocity = cam_velocity.linear_interpolate(cam_input * sensitivity_mouse / 6.5, delta * cam_smoothness)
	player_cam_arm.rotate_x(deg2rad(cam_velocity.y))
	player_cam_arm.rotate_y(deg2rad(cam_velocity.x))
	player_cam_arm.rotation.x = clamp(player_cam_arm.rotation.x, deg2rad(-75), deg2rad(75))
	cam_input = Vector2.ZERO

func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	input_vector.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	return input_vector.normalized() if input_vector.length() > 1 else input_vector

func get_direction(input_vector):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction

func apply_gravity(delta):
	velocity.y += player_gravity * delta
	velocity.y = clamp(velocity.y, player_gravity, player_jump_power)

func update_snap_vector():
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN

func apply_jump():
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		snap_vector = Vector3.ZERO
		velocity.y = player_jump_power
	if Input.is_action_just_released("ui_select") and velocity.y > player_jump_power / 2:
		velocity.y = player_jump_power / 2

func apply_movement(input_vector, direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * player_maximum_speed, player_acceleration * delta).x
		velocity.z = velocity.move_toward(direction * player_maximum_speed, player_acceleration * delta).z
		player_avatar.rotation.y = lerp_angle(player_avatar.rotation.y, atan2(+input_vector.x, +input_vector.z), player_rotation_speed * delta)

func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, player_friction * delta)
		else:
			velocity.x = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).x
			velocity.z = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).z
