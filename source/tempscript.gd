extends RigidBody

onready var mesh: MeshInstance = $MeshInstance

func _ready() -> void:
	mesh.set_surface_material(0, EnvironmentMaster.make_material_unique(mesh.get_surface_material(0)))

func _physics_process(delta: float) -> void:
	EnvironmentMaster.track_light_source(delta, self.get_global_translation(), mesh.get_surface_material(0))
