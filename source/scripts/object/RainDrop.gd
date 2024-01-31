extends RigidBody3D

@onready var sprite: Sprite3D = $Sprite3D
@onready var ray: RayCast3D = $RayCast3D

func _physics_process(_delta: float) -> void:
	if is_instance_valid(sprite):
		if ray.is_colliding():
			sprite.queue_free()
		if is_instance_valid(SB.camera):
			sprite.look_at(SB.camera.global_position, Vector3.UP)
	for p in get_children():
		if p is GPUParticles2D:
			p.one_shot = true
			p.emitting = true
			if p.one_shot == true and p.emitting == false:
				queue_free()
	if global_position.y <= -512:
		queue_free()

func _integrate_forces(_state: PhysicsDirectBodyState3D):
	apply_central_force(Vector3(0, -5, 0))
