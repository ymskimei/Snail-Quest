extends Node

var test_response = "Placeholder"

func test_1(args: Array) -> String:
	#variables are 0=number
	return "EPICAMOUNT: " + args[0]

func set_controlled_name(new_name: String) -> void:
	SnailQuest.get_controlled().get_entity_identity().set_entity_name(new_name)

func get_controlled_name(_args: Array) -> String:
	return tr(SnailQuest.get_controlled().get_entity_identity().get_entity_name())

func set_test_response(new_word: String) -> void:
	test_response = new_word

func get_test_response(_args: Array) -> String:
	return test_response

func update_snail_appearance(id: Resource, mesh: MeshInstance, body: MeshInstance, eye_left: MeshInstance, eye_right: MeshInstance) -> void:
		mesh.set_mesh(id.mesh_shell)
		body.set_mesh(id.mesh_body)
		eye_left.set_mesh(id.mesh_eye_left)
		eye_right.set_mesh(id.mesh_eye_right)

		var body_mat = body.get_surface_material(0)
		var body_accent_mat = body.get_surface_material(0).get_next_pass()

		var eye_left_mat = eye_left.get_surface_material(0).get_next_pass()
		var eye_right_mat = eye_right.get_surface_material(0).get_next_pass()

		var eyelid_left_mat = eye_left.get_surface_material(0).get_next_pass().get_next_pass()
		var eyelid_right_mat = eye_right.get_surface_material(0).get_next_pass().get_next_pass()

		var color_body_highlight: Color = id.color_body_base.from_hsv(id.color_body_base.h, id.color_body_base.s * 1.75, id.color_body_base.v * 0.1)

		var color_body_shade: Color = id.color_shell_accent.from_hsv(id.color_body_base.h, id.color_body_base.s * 1.4, id.color_body_base.v * 0.9)
		
		var color_body_accent: Color
		var color_body_accent_shade: Color
		if id.color_body_accent == Color("00ffffff"):
			color_body_accent = id.color_body_accent.from_hsv(id.color_body_base.h, id.color_body_base.s * 1.2, id.color_body_base.v * 1.3)
			color_body_accent_shade = color_body_accent_shade.from_hsv(id.color_body_base.h, id.color_body_base.s * 1.2, id.color_body_base.v * 0.9)
		else:
			color_body_accent = id.color_body_accent
			color_body_accent_shade = color_body_accent_shade.from_hsv(id.color_body_accent.h, id.color_body_accent.s * 1.4, id.color_body_accent.v * 0.9)

		body_mat.set_shader_param("highlight_color", color_body_highlight)
		body_mat.set_shader_param("albedo_color", id.color_body_base)
		body_mat.set_shader_param("shade_color", color_body_shade)

		body_accent_mat.set_shader_param("texture_albedo", id.pattern_body)
		body_accent_mat.set_shader_param("albedo_color", color_body_accent)
		body_accent_mat.set_shader_param("shade_color", color_body_accent_shade)

		eye_left_mat.set_shader_param("texture_albedo", id.pattern_eyes)
		eye_right_mat.set_shader_param("texture_albedo", id.pattern_eyes)

		eye_left_mat.set_shader_param("albedo_color", id.color_eyes)
		eye_left_mat.set_shader_param("shade_color", id.color_eyes)
		eye_right_mat.set_shader_param("albedo_color", id.color_eyes)
		eye_right_mat.set_shader_param("shade_color", id.color_eyes)

		eyelid_left_mat.set_shader_param("texture_albedo", id.pattern_eyelids)
		eyelid_right_mat.set_shader_param("texture_albedo", id.pattern_eyelids)

		eyelid_left_mat.set_shader_param("albedo_color", id.color_body_base)
		eyelid_left_mat.set_shader_param("shade_color", color_body_shade)
		eyelid_right_mat.set_shader_param("albedo_color", id.color_body_base)
		eyelid_right_mat.set_shader_param("shade_color", color_body_shade)

		if mesh.get_surface_material_count() > 1:
			var shell_mat = mesh.get_surface_material(0)
			var shell_opening = mesh.get_surface_material(1)
			var shell_accent_mat = mesh.get_surface_material(0).get_next_pass()

			var color_shell_shade: Color = id.color_shell_accent.from_hsv(id.color_shell_base.h, id.color_shell_base.s * 1.6, id.color_shell_base.v * 0.85)
			var color_shell_accent_shade: Color = id.color_shell_accent.from_hsv(id.color_shell_accent.h, id.color_shell_accent.s * 1.6, id.color_shell_accent.v * 0.85)

			shell_accent_mat.set_shader_param("texture_albedo", id.pattern_shell)

			shell_mat.set_shader_param("albedo_color", id.color_shell_base)
			shell_mat.set_shader_param("shade_color", color_shell_shade)

			shell_opening.set_shader_param("albedo_color", id.color_body_base)
			shell_opening.set_shader_param("shade_color", color_body_shade)

			shell_accent_mat.set_shader_param("albedo_color", id.color_shell_accent)
			shell_accent_mat.set_shader_param("shade_color", color_shell_accent_shade)

		mesh.get_parent().get_parent().set_scale(Vector3(id.entity_scale, id.entity_scale, id.entity_scale))
