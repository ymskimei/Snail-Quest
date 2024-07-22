extends RigidBody

onready var mesh: MeshInstance = $MeshInstance

func _physics_process(delta: float) -> void:
	EnvironmentMaster.track_light_source(self.get_global_translation(), mesh.get_surface_material(0))
