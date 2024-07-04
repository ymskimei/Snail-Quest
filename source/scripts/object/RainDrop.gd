extends RigidBody

onready var sprite: Sprite3D = $Sprite3D
onready var ray: RayCast = $RayCast

func _physics_process(delta: float) -> void:
	if is_instance_valid(sprite):
		if ray.is_colliding():
			sprite.queue_free()
		if is_instance_valid(Auto.camera):
			sprite.look_at(Auto.camera.global_translation, Vector3.UP)
	for p in get_children():
		if p is Particles2D:
			p.one_shot = true
			p.emitting = true
			if p.one_shot == true and p.emitting == false:
				queue_free()
	if global_translation.y <= -512:
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState):
	add_central_force(Vector3(0, -5, 0))
