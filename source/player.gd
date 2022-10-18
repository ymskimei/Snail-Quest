extends KinematicBody

export var player_name = "Sheldon"

export var player_gravity = -40
export var player_jump_power = 12
export var player_maximum_speed = 9
export var player_acceleration = 70
export var player_friction = 60
export var player_airborne_friction = 15
export var player_rotation_speed = 30

export var cam_smoothness = 20
export var cam_zoom_close = 3
export var cam_zoom_normal = 5
export var cam_zoom_far = 8
var cam_rotation_velocity: Vector2
var cam_input : Vector2
var controller_detected = false

export var mouse_sensitivity = 2
export var controller_sensitivity = 2

var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO

onready var player_cam_arm = $PlayerCameraArm
onready var player_avatar = $PlayerAvatar
onready var player_hitbox = $PlayerHitbox

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_input = event.relative
		controller_detected = false
	elif event is InputEventJoypadMotion:
		controller_detected = true

func _process(delta):
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	if controller_detected:
		cam_input = axis_vector
		cam_rotation_velocity = cam_rotation_velocity.linear_interpolate(cam_input * controller_sensitivity, delta * cam_smoothness / 2)
	else: cam_rotation_velocity = cam_rotation_velocity.linear_interpolate(cam_input * mouse_sensitivity / 5, delta * cam_smoothness)
	player_cam_arm.rotate_x(deg2rad(cam_rotation_velocity.y))
	rotate_y(deg2rad(cam_rotation_velocity.x))
	player_cam_arm.rotation.x = clamp(player_cam_arm.rotation.x, deg2rad(-75), deg2rad(75))
	cam_input = Vector2.ZERO

func _physics_process(delta):
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	apply_gravity(delta)
	update_snap_vector()
	apply_jump()
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_cam_zoom()
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)

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
		#player_hitbox.rotation.y = lerp_angle(player_hitbox.rotation.y, atan2(-input_vector.x, -input_vector.z), player_rotation_speed * delta)

func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, player_friction * delta)
		else:
			velocity.x = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).x
			velocity.z = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).z

func apply_cam_zoom():
	var target: float
	if Input.is_action_just_pressed("cam_zoom"):
		print(player_cam_arm.spring_length)
		if player_cam_arm.spring_length == cam_zoom_far:
			tween_cam_zoom(cam_zoom_normal)
			$WorldAudioPlayer.sfx_cam_zoom_normal.play()
			print("Camera distance altered: Normal")
		elif player_cam_arm.spring_length == cam_zoom_close:
			tween_cam_zoom(cam_zoom_far)
			$WorldAudioPlayer.sfx_cam_zoom_far.play()
			print("Camera distance altered: Far")
		else:
			tween_cam_zoom(cam_zoom_close)
			$WorldAudioPlayer.sfx_cam_zoom_close.play()
			print("Camera distance altered: Close")
			
func tween_cam_zoom(targ):
	var cam_target = targ
	$TweenCamZoom.interpolate_property(player_cam_arm, "spring_length", player_cam_arm.spring_length, cam_target, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$TweenCamZoom.start()
	pass

#var player_name = "Sheldon"
#var player_speed = 7
#var player_jump_power = 15
#var player_gravity = 45
#var velocity = Vector3.ZERO
#var snap_vector = Vector3.DOWN
#onready var spring_arm: SpringArm = $PlayerCameraArm
#onready var model: Spatial = $PlayerModel
#
#func _ready():
#	print("Player name is " + player_name)
#
#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_cancel"):
#		$Pause.pause()
#
#func _physics_process(delta: float) -> void:
#	var move_direction = Vector3.ZERO
#	var player_landed = is_on_floor() and snap_vector == Vector3.ZERO
#	var player_is_jumping = is_on_floor() and Input.is_action_just_pressed("ui_select")
#
#	move_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	move_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
#	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
#	velocity.x = move_direction.x * player_speed
#	velocity.z = move_direction.z * player_speed
#	velocity.y -= player_gravity * delta
#
#	if player_is_jumping:
#		velocity.y = player_jump_power
#		snap_vector = Vector3.ZERO
#	elif player_landed:
#		snap_vector = Vector3.DOWN
#	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
#
#	if velocity.length() > 0.2:
#		var look_direction = Vector2(velocity.z, velocity.x)
#		model.rotation.y = look_direction.angle() 
#
#func _process(_delta: float) -> void:
#	spring_arm.translation = translation
