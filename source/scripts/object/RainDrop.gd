extends RigidBody

onready var sprite: Sprite3D = $Sprite3D
onready var ray: RayCast = $RayCast

func _physics_process(delta: float) -> void:
	if is_instance_valid(GlobalManager.camera):
		sprite.look_at(GlobalManager.camera.global_translation, Vector3.UP)
	if ray.is_colliding():
		sprite.queue_free()
		for p in get_children():
			if p is Particles2D:
				p.one_shot = true
				p.emitting = true
				if p.one_shot == true and p.emitting == false:
					queue_free()
	if is_instance_valid(GlobalManager.camera):
		if global_translation.y <= -512:
			queue_free()
