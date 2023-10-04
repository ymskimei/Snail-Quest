class_name Snail
extends Entity

export(Resource) var skin

onready var climbing_rays: Spatial = $Checkers/ClimbingRays

var cursor = preload("res://source/scenes/gui/gui_aim_cursor.tscn")

var in_shell: bool
var is_tool_equipped: bool
var cursor_activated: bool

var cursor_pos: Vector3

func _ready() -> void:
	entity_name = skin.entity_name
	states.ready(self)
	update_appearance()
	set_interaction_text("")

func _input(event: InputEvent) -> void:
	if is_controllable():
		states.input(event)

func _unhandled_input(event: InputEvent) -> void:
	if is_controllable():
		states.unhandled_input(event)

func _physics_process(delta: float) -> void:
	._physics_process(delta)
	if is_controllable():
		states.physics_process(delta)
	if in_shell:
		attach_point.visible = false
	else:
		attach_point.visible = true

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	if is_controllable():
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

func update_appearance() -> void:
	var shell = $"%Shell"
	var body = $"%Body"
	var eye_left = $"%EyeLeft"
	var eye_right = $"%EyeRight"
	var shell_mat = shell.get_surface_material(0)
	var shell_accent_mat = shell.get_surface_material(0).get_next_pass()
	var shell_body_mat = shell.get_surface_material(1)
	var body_mat = body.get_surface_material(0)
	var body_accent_mat = body.get_surface_material(0).get_next_pass()
	var eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
	var eye_right_mat = eye_right.get_surface_material(0).get_next_pass()
	var eyelid_left_mat = eye_left.get_surface_material(0).get_next_pass().get_next_pass()
	var eyelid_right_mat = eye_right.get_surface_material(0).get_next_pass().get_next_pass()
	shell.set_mesh(skin.mesh_shell)
	body.set_mesh(skin.mesh_body)
	eye_left.set_mesh(skin.mesh_eye_left)
	eye_right.set_mesh(skin.mesh_eye_right)
	shell_accent_mat.set_shader_param("texture_albedo", skin.pattern_shell)
	body_accent_mat.set_shader_param("texture_albedo", skin.pattern_body)
	eye_left_mat.set_shader_param("texture_albedo", skin.pattern_eyes)
	eye_right_mat.set_shader_param("texture_albedo", skin.pattern_eyes)
	shell_mat.set_shader_param("albedo", Color(skin.color_shell_base))
	shell_accent_mat.set_shader_param("albedo", Color(skin.color_shell_accent))
	shell_body_mat.set_shader_param("albedo", Color(skin.color_body))
	body_mat.set_shader_param("albedo", Color(skin.color_body))
	body_accent_mat.set_shader_param("albedo", Color(skin.color_body_accent))
	eye_left_mat.set_shader_param("albedo", Color(skin.color_eye_left))
	eye_right_mat.set_shader_param("albedo", Color(skin.color_eye_right))
	if skin.pattern_eyelids != null:
		eyelid_left_mat.set_shader_param("texture_albedo", skin.pattern_eyelids)
		eyelid_right_mat.set_shader_param("texture_albedo", skin.pattern_eyelids)
		eyelid_left_mat.set_shader_param("albedo", Color(skin.color_body_accent))
		eyelid_right_mat.set_shader_param("albedo", Color(skin.color_body_accent))
	else:
		eyelid_left_mat.set_shader_param("albedo", Color(0, 0, 0, 0))
		eyelid_right_mat.set_shader_param("albedo", Color(0, 0, 0, 0))
