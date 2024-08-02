class_name EnvironmentMeshInstance
extends MeshInstance

var update_lighting: int = 0
var within_visual_limiter: bool = false
var can_update_lighting: bool = true
var new_lighting_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	if get_surface_material(0) is ShaderMaterial and get_surface_material(0).get_shader().has_param("light_direction"):
		if get_parent() is RigidBody:
			update_lighting = 1
		elif get_node("../../../") is Entity:
			update_lighting = 2
		else:
			update_lighting = 0
		set_surface_material(0, EnvironmentMaster.make_material_unique(get_surface_material(0)))

func _physics_process(delta: float) -> void:
	if within_visual_limiter:
		if update_lighting == 1:
			if get_parent().get_linear_velocity().length() > 0.1:
				can_update_lighting = true
		elif update_lighting == 2:
			if get_node("../../../").direction.length() > 0.1:
				can_update_lighting = true

		if can_update_lighting and update_lighting > 0:
			if get_surface_material(0) is ShaderMaterial:
				new_lighting_position = EnvironmentMaster.track_light_source(delta, self.get_global_translation(), get_surface_material(0).get_shader_param("light_direction"))
				for i in get_surface_material_count():
					get_surface_material(i).set_shader_param("light_direction", new_lighting_position)

func set_within_visual_limiter(toggle: bool) -> void:
	within_visual_limiter = toggle

func get_within_visual_limiter() -> bool:
	return within_visual_limiter
