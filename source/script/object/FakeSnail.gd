extends RigidBody

export var identity: Resource = null

onready var armature: Spatial = $Armature
onready var collision: CollisionShape = $CollisionShape

onready var mesh: MeshInstance = $Armature/Skeleton/MeshInstance
onready var body: MeshInstance = $Armature/Skeleton/Body
onready var eye_left: MeshInstance = $Armature/Skeleton/BoneAttachment2/EyeLeft
onready var eye_right: MeshInstance = $Armature/Skeleton/BoneAttachment/EyeRight
onready var hat: MeshInstance = $Armature/Skeleton/BoneAttachment3/Hat
onready var sticker: MeshInstance = $Armature/Skeleton/BoneAttachment3/Sticker

onready var anim: AnimationPlayer = $AnimationPlayer
onready var listener: Listener = $Listener

var real_body = load("res://source/scene/entity/snail.tscn")

var input_direction: Vector2
var orientating: bool = false
var is_in_shell: bool = false

func _ready() -> void:
	var visibility = VisibilityEnabler.new()
	visibility.set_enabler(VisibilityEnabler.ENABLER_FREEZE_BODIES, false)
	visibility.set_enabler(VisibilityEnabler.ENABLER_PAUSE_ANIMATIONS, true)
	add_child(visibility)
	Functions.update_snail_appearance(identity, mesh, body, eye_left, eye_right)
	if is_in_shell:
		anim.play("SnailHidden")
	else:
		anim.play("SnailSquirm")

func _unhandled_input(event: InputEvent) -> void:
	if is_controlled():
		input_direction.x = Input.get_axis(Device.stick_main_left, Device.stick_main_right)
		input_direction.y = Input.get_axis(Device.stick_main_up, Device.stick_main_down)

		if event.is_action_released(Device.trigger_right) or event.is_action_pressed(Device.action_main):
			var snail: KinematicBody = Utility.physics_to_kinematic_body(self)
			if event.is_action_pressed(Device.action_main):
				snail.jump_in_memory = true
			snail.was_just_in_shell = true
			get_parent().add_child(snail)
			snail.set_global_translation(get_global_translation() + Vector3.UP * 0.5)
			snail.set_global_rotation(Vector3(0, get_rotation_degrees().y, 0))
			print(get_rotation_degrees().y)
			SnailQuest.set_controlled(snail)
			queue_free()

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	if is_controlled():
		state.apply_central_impulse(Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, SnailQuest.get_camera().get_global_rotation().y) * 0.55)
		#state.add_torque(Vector3(-0.3, 0, -0.3))

	elif get_linear_velocity().length() < 0.01:
		state.apply_central_impulse(Vector3.UP * 20)
		orientating = true
		var timer = Timer.new()
		timer.set_wait_time(0.5)
		timer.set_one_shot(true)
		timer.connect("timeout", self, "_on_timeout")
		add_child(timer)
		timer.start()

func _on_timeout() -> void:
	var snail: KinematicBody = Utility.physics_to_kinematic_body(self)
	get_parent().add_child(snail)
	snail.set_global_translation(get_global_translation() + Vector3.UP * 0.3)
	snail.set_global_rotation(Vector3(0, get_rotation_degrees().y, 0))
	queue_free()

func hide_snail_body() -> void:
	body.set_visible(false)
	eye_left.set_visible(false)
	eye_right.set_visible(false)

func get_coords(raw: bool = false) -> Vector3:
	var x = get_global_translation().x
	var y = get_global_translation().y
	var z = get_global_translation().z
	if !raw:
		x = round(x)
		y = round(y)
		z = round(z)
	var coords = [x, y, z]
	return coords

func set_coords(position: Vector3, angle: String = "NORTH") -> void:
	set_global_translation(position)
	set_global_rotation(Vector3(0, deg2rad(Utility.cardinal_to_degrees(angle)), 0))

func is_controlled() -> bool:
	if SnailQuest.controlled == self:
		return true
	return false

func set_entity_identity(appearance: Resource) -> void:
	identity = appearance

func get_entity_identity() -> Resource:
	return identity

func get_kinematic_body() -> PackedScene:
	return real_body
