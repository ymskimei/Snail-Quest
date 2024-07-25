class_name EnvironmentMeshInstance
extends MeshInstance

#var original_albedo_color: Color

func _ready() -> void:
	if get_surface_material(0) is ShaderMaterial:
#		set_original_albedo_color(get_surface_material(0).get_shader_param("albedo_color"))

		if get_surface_material(0).get_shader().has_param("light_direction"):
			set_surface_material(0, EnvironmentMaster.make_material_unique(get_surface_material(0)))

func _physics_process(delta: float) -> void:
	if get_surface_material(0) is ShaderMaterial:
		EnvironmentMaster.track_light_source(delta, self.get_global_translation(), get_surface_material(0))

#func _on_game_time_active() -> void:
#	SnailQuest.get_game_time().connect("on_second", self, "_on_second_advanced")

#func _on_second_advanced() -> void:
#	if get_original_albedo_color():
#		for n in get_surface_material_count():

#			if get_surface_material(n):
#				get_surface_material(n).set_shader_param("highlight_color", EnvironmentMaster.get_material_color(get_original_albedo_color())[0])
#				get_surface_material(n).set_shader_param("albedo_color", EnvironmentMaster.get_material_color(get_original_albedo_color())[1])
#				get_surface_material(n).set_shader_param("shade_color", EnvironmentMaster.get_material_color(get_original_albedo_color())[2])

#			if get_surface_material(n).get_next_pass():
#				get_surface_material(n).get_next_pass().set_shader_param("highlight_color", EnvironmentMaster.get_material_color(get_original_albedo_color())[0])
#				get_surface_material(n).get_next_pass().set_shader_param("albedo_color", EnvironmentMaster.get_material_color(get_original_albedo_color())[1])
#				get_surface_material(n).get_next_pass().set_shader_param("shade_color", EnvironmentMaster.get_material_color(get_original_albedo_color())[2])

#func set_original_albedo_color(color: Color) -> void:
#	original_albedo_color = color

#func get_original_albedo_color() -> Color:
#	return original_albedo_color
