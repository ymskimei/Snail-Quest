extends KinematicBody

#Main Variables
export var player_name = "Sheldon"

#Health Variables
#signal health_increased
#signal health_depleted
#signal health_status
#
#export var _player_health = 0
#export var player_maximum_health = 0
#var player_health_status = null
#
#export var poison_cycles = 0
#const POISON_DAMAGE = 1
#
#enum StatusEffects {
#	STATUS_NONE,
#	STATUS_INVINCIBLE
#	STATUS_POISONED,
#	STATUS_STUNNED
#}

#Movement Variables
export var player_maximum_speed = 7
export var player_acceleration = 70
export var player_friction = 60
export var player_airborne_friction = 4
export var player_jump_power = 10
export var player_gravity = -30
export var player_rotation_speed = 25
export var mouse_sensitivity = 0.1
export var controller_sensitivity = 2
var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO

#Node Variables
onready var player_camera_arm = $PlayerCameraArm
onready var player_avatar = $Rotation/PlayerAvatar
onready var player_hitbox = $PlayerHitbox

#Setup
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PoisonTimer.connect('timeout', self, '_on_PoisonTimer_timeout')
	climbing_checker.connect('body_entered', self, 'body_entered')

# Bug Copy Paste

onready var raycast_folder = $RayCast
onready var direction_checker = $Rotation/DirectionChecker
onready var climbing_checker = $ClimbingChecker

var gravity := Vector3(0,-3,0)
var jumpVec := Vector3(0, 10, 0)
var avgNormal : Vector3 = Vector3.ZERO
var speed := 3.0
var vel := Vector3.ZERO
var jumpNum := 0
var maxJumpAmt := 10
var extraVel := Vector3.ZERO
var theUpDir := Vector3.UP
var jumpVectors := Vector3.ZERO
var bodyOn : StaticBody
var mouseSensMulti := 1

func body_entered(body:PhysicsBody) -> void:
	if body and body != bodyOn and body is StaticBody:
		bodyOn = body
		jumpVectors = Vector3.ZERO

func checkRays() -> void:
	var avgNor := Vector3.ZERO
	var numOfRaysColliding := 0
	for ray in raycast_folder.get_children():
		var r : RayCast = ray
		if r.is_colliding() and r.get_collider() != $PlayerHitbox.get_parent():
			numOfRaysColliding += 1
			avgNor += r.get_collision_normal()
	if avgNor:
		avgNor /= numOfRaysColliding
		avgNormal = avgNor.normalized()
	else: 
		avgNormal = Vector3.UP
	print(numOfRaysColliding);
	print(avgNormal);
	jumpVec = avgNormal * 20
	gravity = avgNormal * -3

func jump() -> void:
	jumpVectors += jumpVec
	avgNormal = Vector3.UP
	jumpVec = avgNormal * 20
	gravity = avgNormal * -3

func _physics_process(delta: float) -> void:
	apply_controller_rotation()
	vel = speed * get_dir()
	checkRays()
	if not is_on_floor():
		jumpVectors += gravity
		avgNormal = Vector3.UP
	elif is_on_floor():
		jumpVectors = Vector3.ZERO
	if Input.is_action_just_pressed("ui_select"):
		jump() 
	vel += jumpVectors
	vel = move_and_slide(vel, avgNormal.normalized())

func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( direction_checker.global_transform.origin - player_hitbox.global_transform.origin  ).normalized()
	var dirBase :Vector3= avgNormal.cross( fowardDir ).normalized()
	if Input.is_action_pressed("ui_up"):
		dir = dirBase.rotated( avgNormal.normalized(), -PI/2 )
	if Input.is_action_pressed("ui_down"):
		dir = dirBase.rotated( avgNormal.normalized(), PI/2 )
	if Input.is_action_pressed("ui_left"):
		dir = dirBase
	if Input.is_action_pressed("ui_right"):
		dir = dirBase.rotated(avgNormal.normalized(), PI)
	return dir.normalized()

# Bug Copy Paste


#Movement
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		#$Rotation.rotation.x = avgNormal.normalized().x
		#$Rotation.rotation.z = avgNormal.normalized().z
		player_camera_arm.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))

func _physics_processOLD(delta):
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	jump()
	apply_controller_rotation()
	player_camera_arm.rotation.x = clamp(player_camera_arm.rotation.x, deg2rad(-75), deg2rad(75))
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)

func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input_vector.normalized() if input_vector.length() > 1 else input_vector

func get_direction(input_vector):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction

func apply_movement(input_vector, direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * player_maximum_speed, player_acceleration * delta).x
		velocity.z = velocity.move_toward(direction * player_maximum_speed, player_acceleration * delta).z
		player_avatar.rotation.y = lerp_angle(player_avatar.rotation.y, atan2(-input_vector.x, -input_vector.z), player_rotation_speed * delta)
		#player_hitbox.rotation.y = lerp_angle(player_hitbox.rotation.y, atan2(-input_vector.x, -input_vector.z), player_rotation_speed * delta)

func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, player_friction * delta)
		else:
			velocity.x = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).x
			velocity.z = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).z

func apply_gravity(delta):
	velocity.y += player_gravity * delta
	velocity.y = clamp(velocity.y, player_gravity, player_jump_power)

func update_snap_vector():
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN

func jumpOLD():
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		snap_vector = Vector3.ZERO
		velocity.y = player_jump_power
	if Input.is_action_just_released("ui_select") and velocity.y > player_jump_power / 3:
		velocity.y = player_jump_power / 3

func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	if InputEventJoypadMotion:
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		player_camera_arm.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity / 1.3)

#Health System
#func _change_status(player_new_health_status):
#	match player_health_status:
#		StatusEffects.STATUS_POISONED:
#			$PoisonTimer.stop()

#	match player_new_health_status:
#		StatusEffects.STATUS_POISONED:
#			poison_cycles = 0
#			$PoisonTimer.start()
#	player_health_status = player_new_health_status
#	emit_signal('status_changed', player_new_health_status)

#func take_damage(amount, effect = null):
#	if player_health_status == StatusEffects.STATUS_INVINCIBLE:
#		return
#	_player_health -= amount
#	_player_health = max(0, _player_health)
#	emit_signal("health_changed", _player_health)

#	if not effect:
#		return
#	match effect[0]:
#		StatusEffects.STATUS_POISONED:
#			_change_status(StatusEffects.STATUS_POISONED)
#			poison_cycles = effect[1]

#func heal(amount):
#	_player_health += amount
#	_player_health = min(_player_health, player_maximum_health)
#	emit_signal("health_changed", _player_health)

#func _on_PoisonTimer_timeout():
#	take_damage(POISON_DAMAGE)
#	poison_cycles -= 1
#	if poison_cycles == 0:
#		_change_status(StatusEffects.STATUS_NONE)
#		return
#	$PoisonTimer.start()
