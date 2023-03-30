class_name Player
extends EntityParent

onready var player_cam = get_parent().get_node("Camera")
onready var avatar = $PlayerAvatar
onready var states = $StateController
onready var interaction_label = $Gui/InteractionLabel

onready var interactor = $"%CheckerInteraction"
onready var jump_check = $"%CheckerFloor"

signal health_changed
signal player_killed

var snap_vector = Vector3.ZERO
var targeting : bool
var current_collider
var collider
var can_interact : bool
var target = null
var interactable = null

#signal play_battle_tracks

func _ready():
	states.ready(self)
	set_interaction_text("")

func _physics_process(delta: float) -> void:
	states.physics_process(delta)
	if target == null:
		target = MathHelper.find_target(self, "target")
	else:
		target_check()

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		inflict_damage(body.strength)

func inflict_damage(damage_amount):
	set_current_health(health - damage_amount)
	print("Player Health: " + str(health))

func set_current_health(new_amount):
	health = new_amount
	emit_signal("health_changed", new_amount)
	if health <= 0:
		kill_player()
		print("Player Died")

func kill_player():
	emit_signal("player_killed")

func target_check():
	var target_distance = target.get_global_translation().distance_to(get_global_translation())
	var relative_facing = target.get_global_transform().basis.z.dot(get_global_transform().origin - target.get_global_transform().origin)
	var max_enemy_distance = 15
	var max_interactable_distance = 2
	if Input.is_action_pressed("cam_lock"):
		if target is EnemyParent and target_distance < max_enemy_distance or ObjectInteractable and target_distance < max_interactable_distance:
			targeting = true
		else:
			targeting = false
	else:
		target = MathHelper.find_target(self, "target")
		targeting = false
	if target is ObjectInteractable and target_distance < max_interactable_distance and relative_facing >= 0:
		can_interact = true
		set_interaction_text(target.get_interaction_text())
		if Input.is_action_just_pressed("action_main"):
			target.interact()
			set_interaction_text("")
	else:
		can_interact = false
		set_interaction_text("")

func set_interaction_text(text):
	if !text:
		interaction_label.set_text("")
		interaction_label.set_visible(false)
	else:
		var interaction_key = OS.get_scancode_string(InputMap.get_action_list("action_main")[0].scancode)
		interaction_label.set_text("Press %s to %s" % [interaction_key, text])
		interaction_label.set_visible(true)

#export var player_gravity = -110
#export var player_jump_power = 30
#export var player_maximum_speed = 7
#export var player_acceleration = 200
#export var player_friction = 60
#export var player_airborne_friction = 40
#export var player_rotation_speed = 30
#
#var velocity = Vector3.ZERO
#var snap_vector = Vector3.ZERO
#var ground = []
#var did_jump = false
#
#onready var player_avatar = $PlayerAvatar
#onready var player_hitbox = $PlayerHitbox
#onready var player_cam = get_node("/root/Game/Camera")
#
#func _ready():
#	#world_variables.register_player(self)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#
#func _physics_process(delta):
#	var input_vector = get_input_vector()
#	var direction = get_direction(input_vector)
#	apply_gravity(delta)
#	update_snap_vector()
#	apply_jump(delta)
#	apply_movement(input_vector, direction, delta)
#	apply_friction(direction, delta)
#	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
#
#func get_input_vector():
#	var input_vector = Vector3.ZERO
#	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	input_vector.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
#	return input_vector
#
#func get_direction(input_vector):
#	var direction = input_vector.rotated(Vector3.UP, player_cam.rotation.y).normalized()
#	return direction
#
#func apply_gravity(delta):
#	velocity.y += player_gravity * delta
#	velocity.y = clamp(velocity.y, player_gravity, player_jump_power)
#
#func update_snap_vector():
#	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN
#
#func apply_jump(delta):
#	if Input.is_action_just_pressed("ui_select") and is_on_floor() || Input.is_action_just_pressed("ui_select"): #and $PlayerRays/RayFloor.is_colliding()
#		snap_vector = Vector3.ZERO
#		velocity.y = player_jump_power
#	if Input.is_action_just_released("ui_select") and velocity.y > player_jump_power / 2:
#		velocity.y = player_jump_power / 2
#
#func apply_movement(input_vector, direction, delta):
#	if direction != Vector3.ZERO:
#		velocity.x = velocity.move_toward(direction * player_maximum_speed, player_acceleration * delta).x
#		velocity.z = velocity.move_toward(direction * player_maximum_speed, player_acceleration * delta).z
#		player_avatar.rotation.y = lerp_angle(player_avatar.rotation.y, atan2(-input_vector.x, -input_vector.z), player_rotation_speed * delta)
#
#func apply_friction(direction, delta):
#	if direction == Vector3.ZERO:
#		if is_on_floor():
#			velocity = velocity.move_toward(Vector3.ZERO, player_friction * delta)
#		else:
#			velocity.x = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).x
#			velocity.z = velocity.move_toward(direction * player_maximum_speed, player_airborne_friction * delta).z
#
#func can_jump():
#	return ground.size() or not ($AllowJump.is_stopped() or did_jump)



