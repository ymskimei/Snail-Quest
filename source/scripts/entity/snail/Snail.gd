class_name Snail
extends Entity

onready var climbing_rays: Spatial = $Checkers/ClimbingRays
onready var ray_front_top: RayCast = $Armature/Skeleton/Rays/RayFrontTop
onready var ray_front_bottom: RayCast = $Armature/Skeleton/Rays/RayFrontBottom
onready var ray_ledge_left: RayCast = $Armature/Skeleton/Rays/RayLedgeLeft
onready var ray_ledge_right: RayCast = $Armature/Skeleton/Rays/RayLedgeRight
onready var ray_bottom: RayCast = $Armature/Skeleton/Rays/RayBottom

var cursor = preload("res://source/scenes/ui/gui_aim_cursor.tscn")

var in_shell: bool
var is_tool_equipped: bool
var cursor_activated: bool
var attached_to_location: bool

var cursor_pos: Vector3

func _ready() -> void:
	states.ready(self)
	update_appearance()
	set_interaction_text("")
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

func _physics_process(delta: float) -> void:
	._physics_process(delta)
	if is_controlled():
		states.physics_process(delta)
	elif is_instance_valid(SnailQuest.controllable) and self == SnailQuest.prev_controllable:
		if SnailQuest.controllable.get("grab_point"):
			anim.play("SnailGrab")
			global_translation = SnailQuest.controllable.grab_point.global_translation
			global_rotation.x = SnailQuest.controllable.grab_point.global_rotation.x
			global_rotation.y = 0
			global_rotation.z = SnailQuest.controllable.grab_point.global_rotation.z
	if in_shell:
		attach_point.visible = false
	else:
		attach_point.visible = true
	update_appearance()

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	states.integrate_forces(state)

func _on_proximity_entered(body) -> void:
	if body is Enemy:
		enemy_detected = true

func _on_proximity_exited(body) -> void:
	if body is Enemy:
		enemy_detected = false

func _on_Area_area_entered(area) -> void:
	if area.is_in_group("danger"):
		damage_entity(area.get_parent().strength)
	if area.is_in_group("attachable"):
		SnailQuest.set_prev_controllable(self)
		SnailQuest.set_controllable(area.get_parent().get_parent().get_parent())
		attached_to_location = true

func update_appearance() -> void:
	var shell = $"%Shell"
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
	if is_instance_valid(identity):
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
		body_mat.set_shader_param("albedo_color", identity.color_body)
		body_mat.set_shader_param("shade_color", identity.color_body_shade)
		body_accent_mat.set_shader_param("texture_albedo", identity.pattern_body)
		eye_left_mat.set_shader_param("albedo_color", identity.color_eye_left)
		eye_right_mat.set_shader_param("albedo_color", identity.color_eye_right)
		eyelid_left_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
		eyelid_right_mat.set_shader_param("texture_albedo", identity.pattern_eyelids)
		eyelid_left_mat.set_shader_param("albedo_color", identity.color_body_accent)
		eyelid_right_mat.set_shader_param("albedo_color", identity.color_body_accent)
