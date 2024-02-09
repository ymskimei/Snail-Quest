class_name Snail
extends Entity

onready var climbing_rays: Spatial = $Checkers/ClimbingRays
onready var ray_front_top: RayCast = $Armature/Skeleton/Rays/RayFrontTop
onready var ray_front_bottom: RayCast = $Armature/Skeleton/Rays/RayFrontBottom
onready var ray_ledge_left: RayCast = $Armature/Skeleton/Rays/RayLedgeLeft
onready var ray_ledge_right: RayCast = $Armature/Skeleton/Rays/RayLedgeRight
onready var ray_bottom: RayCast = $Armature/Skeleton/Rays/RayBottom
onready var holding_point: Spatial = $"%HoldingPoint"
var cursor = preload("res://source/scenes/interface/cursor_aim.tscn")

var in_shell: bool = false
var is_tool_equipped: bool = false
var cursor_activated: bool = false
var colliding: bool = false

var cursor_pos: Vector3 = Vector3.ZERO
var mode_timer: Timer = null

func _ready() -> void:
	states.ready(self)
	#update_appearance()
	set_interaction_text("")
	mode_timer = Timer.new()
	mode_timer.set_wait_time(0.1)
	mode_timer.one_shot = true
	mode_timer.connect("timeout", self, "_on_mode_timeout")
	add_child(mode_timer)
#	if character:
#		char_target.visible = true
#	elif !character:
#		char_target.visible = false

func _input(event: InputEvent) -> void:
	if is_controlled():
		states.input(event)

func _unhandled_input(event: InputEvent) -> void:
	if is_controlled():
		states.unhandled_input(event)

func _process(delta: float) -> void:
	._process(delta)

func _physics_process(delta: float) -> void:
	update_appearance()
	if is_controlled():
		states.physics_process(delta)
	elif SB.controlled and self == SB.prev_controlled:
		if SB.controlled.get("grab_point"):
			anim.play("SnailGrab")
			global_translation = SB.controlled.grab_point.global_translation
			global_rotation.x = SB.controlled.grab_point.global_rotation.x
			global_rotation.y = 0
			global_rotation.z = SB.controlled.grab_point.global_rotation.z
	if in_shell:
		holding_point.visible = false
	else:
		holding_point.visible = true

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	states.integrate_forces(state)

func _on_proximity_entered(body) -> void:
	if body is Enemy:
		enemy_found = true

func _on_proximity_exited(body) -> void:
	if body is Enemy:
		enemy_found = false

func update_appearance() -> void:
	var shell = $"%MeshInstance"
	var body = $"%Body"
	var eye_left = $"%EyeLeft"
	var eye_right = $"%EyeRight"
	var shell_mat = shell.get_surface_material(0)
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
		shell_mat.set_shader_param("shade_color", identity.color_shell_base_shade)
		shell_accent_mat.set_shader_param("albedo_color", identity.color_shell_accent)
		body_mat.set_shader_param("specular_color", identity.color_body_specular)
		body_mat.set_shader_param("rim_color", identity.color_body_specular)
		body_mat.set_shader_param("albedo_color", identity.color_body_base)
		body_mat.set_shader_param("shade_color", identity.color_body_shade)
		body_accent_mat.set_shader_param("texture_albedo", identity.pattern_body)
		body_accent_mat.set_shader_param("albedo_color", identity.color_body_accent)
		eye_left_mat.set_shader_param("albedo_color", identity.color_eyes)
		eye_right_mat.set_shader_param("albedo_color", identity.color_eyes)
		eyelid_left_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
		eyelid_right_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
		eyelid_left_mat.set_shader_param("albedo_color", identity.color_body_accent)
		eyelid_right_mat.set_shader_param("albedo_color", identity.color_body_accent)

func play_sound_slide(s: bool) -> void:
	if s:
		Audio.play_pos_sfx(RegistryAudio.snail_slide_backward, global_translation, 1.0, -1.0)
	else:
		Audio.play_pos_sfx(RegistryAudio.snail_slide_forward, global_translation, 1.25, -1.0)

func play_sound_hide(s: bool) -> void:
	if s:
		Audio.play_pos_sfx(RegistryAudio.snail_shell_in, global_translation, 1.0, 0.0)
	else:
		Audio.play_pos_sfx(RegistryAudio.snail_shell_out, global_translation, 0.5, 0.0)

func _on_Snail_body_entered(body) -> void:
	if !body.get_collision_layer_bit(2):
		colliding = true
		mode_timer.start()

func _on_Snail_body_exited(body) -> void:
	if !body.get_collision_layer_bit(2):
		colliding = false
		mode_timer.start()

func _on_mode_timeout() -> void:
	if !is_controlled():
		if !colliding:
			mode = RigidBody.MODE_STATIC
			print(entity_name)
		else:
			mode = RigidBody.MODE_RIGID
	else:
		mode = RigidBody.MODE_CHARACTER
