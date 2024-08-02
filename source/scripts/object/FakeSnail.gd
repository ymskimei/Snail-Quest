extends RigidBody

export var identity: Resource = null

onready var armature: Spatial = $Armature
onready var collision: CollisionShape = $CollisionShape
onready var shell: MeshInstance = $Armature/Skeleton/MeshInstance
onready var body: MeshInstance = $Armature/Skeleton/Body
onready var eye_left: MeshInstance = $Armature/Skeleton/BoneAttachment2/EyeLeft
onready var eye_right: MeshInstance = $Armature/Skeleton/BoneAttachment/EyeRight
onready var hat: MeshInstance = $Armature/Skeleton/BoneAttachment3/Hat
onready var sticker: MeshInstance = $Armature/Skeleton/BoneAttachment3/Sticker
onready var anim: AnimationPlayer = $AnimationPlayer

var orientating: bool = false

func _ready() -> void:
	var shell_mat = shell.get_surface_material(0)
	var shell_opening = shell.get_surface_material(1)
	var shell_accent_mat = shell.get_surface_material(0).get_next_pass()
	var body_mat = body.get_surface_material(0)
	var body_accent_mat = body.get_surface_material(0).get_next_pass()
	var eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
	var eye_right_mat = eye_right.get_surface_material(0).get_next_pass()
	var eyelid_left_mat = eye_left.get_surface_material(0).get_next_pass().get_next_pass()
	var eyelid_right_mat = eye_right.get_surface_material(0).get_next_pass().get_next_pass()
	if identity:
		shell.set_mesh(identity.mesh_shell)
		body.set_mesh(identity.mesh_body)
		eye_left.set_mesh(identity.mesh_eye_left)
		eye_right.set_mesh(identity.mesh_eye_right)

		shell_accent_mat.set_shader_param("texture_albedo", identity.pattern_shell)

		eye_left_mat.set_shader_param("texture_albedo", identity.pattern_eyes)
		eye_right_mat.set_shader_param("texture_albedo", identity.pattern_eyes)

		shell_mat.set_shader_param("albedo_color", identity.color_shell_base)
		shell_mat.set_shader_param("shade_color", identity.color_shell_shade)
		shell_opening.set_shader_param("albedo_color", identity.color_body_base)
		shell_opening.set_shader_param("shade_color", identity.color_body_shade)

		shell_accent_mat.set_shader_param("albedo_color", identity.color_shell_accent)
		shell_accent_mat.set_shader_param("shade_color", identity.color_shell_accent)

		body_mat.set_shader_param("specular_color", identity.color_body_specular)
		body_mat.set_shader_param("rim_color", identity.color_body_specular)
		body_mat.set_shader_param("albedo_color", identity.color_body_base)
		body_mat.set_shader_param("shade_color", identity.color_body_shade)

		body_accent_mat.set_shader_param("texture_albedo", identity.pattern_body)
		body_accent_mat.set_shader_param("albedo_color", identity.color_body_accent)
		body_accent_mat.set_shader_param("shade_color", identity.color_body_shade)

		eye_left_mat.set_shader_param("albedo_color", identity.color_eyes)
		eye_left_mat.set_shader_param("shade_color", identity.color_eyes)
		eye_right_mat.set_shader_param("albedo_color", identity.color_eyes)
		eye_right_mat.set_shader_param("shade_color", identity.color_eyes)

		eyelid_left_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
		eyelid_right_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)

		eyelid_left_mat.set_shader_param("albedo_color", identity.color_body_base)
		eyelid_left_mat.set_shader_param("shade_color", identity.color_body_shade)
		eyelid_right_mat.set_shader_param("albedo_color", identity.color_body_base)
		eyelid_right_mat.set_shader_param("shade_color", identity.color_body_shade)

	anim.play("SnailSquirm")

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	if get_linear_velocity().length() < 0.1:
		state.apply_central_impulse(Vector3.UP * 20)
		orientating = true
		var timer = Timer.new()
		timer.set_wait_time(0.5)
		timer.set_one_shot(true)
		timer.connect("timeout", self, "_on_timeout")
		add_child(timer)
		timer.start()

func _on_timeout() -> void:
	var snail: KinematicBody = load("res://source/scenes/entity/snail.tscn").instance()
	snail.set_entity_identity(get_entity_identity())
	get_parent().add_child(snail)
	snail.set_global_translation(get_global_translation() + Vector3.UP * 0.3)
	snail.set_global_rotation(Vector3(0, get_rotation_degrees().y, 0))
	queue_free()

func set_entity_identity(appearance: Resource) -> void:
	identity = appearance

func get_entity_identity() -> Resource:
	return identity
