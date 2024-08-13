class_name StateMain
extends Node

var entity: Entity = null

func print_state_name(state_names: Array, state: int) -> void:
	print(entity.get_entity_identity().get_entity_name() + "'s state is " + state_names[state])

func set_movement(delta: float, speed_modifier: float = 1.0, turn_modifier: float = 1.0, lerp_speed: float = 20) -> void:
	#entity.rotation = Vector3.ZERO
	#entity.rotation = entity.rotation.rotated(Vector3.LEFT, entity.surface_normal.z)
	#entity.global_transform = Utility.align_from_transform(entity.global_transform, entity.surface_normal)

	entity.global_transform = Utility.align_from_transform(entity.global_transform, entity.surface_normal)

	entity.modified_input_direction = Vector3(entity.input_direction.x * turn_modifier, 0, entity.input_direction.y)
	if entity.floor_angle > 90:
		pass
	
	if entity.is_controlled():
		entity.modified_input_direction = entity.modified_input_direction.rotated(Vector3.UP, SnailQuest.get_camera().get_global_rotation().y)

	entity.modified_input_direction = (entity.modified_input_direction - entity.surface_normal * entity.surface_normal.dot(entity.modified_input_direction)).normalized()

	if entity.modified_input_direction.length() > 0.01:
		entity.facing_angle = atan2(-entity.modified_input_direction.x, -entity.modified_input_direction.z)
	entity.rotation.y = lerp_angle(entity.rotation.y, entity.facing_angle, 12 * delta)

	#entity.modified_input_direction = entity.modified_input_direction.rotated(Vector3.LEFT, entity.rotation.x)

	#entity.modified_input_direction = entity.modified_input_direction.rotated(Vector3.LEFT, entity.rotation.x)


	entity.move_direction = lerp(entity.move_direction, entity.modified_input_direction * speed_modifier * 4, 24 * delta)
	if entity.mirrored_movement:
		entity.move_direction = -entity.move_direction

	## physics interaction ##

	for i in entity.get_slide_count():
		var c = entity.get_slide_collision(i)
		if c.collider is RigidBody:
			c.collider.apply_central_impulse(-c.normal * (0.25 + (entity.move_momentum * 50)))

	if entity.surface_rays:
		for ray in entity.surface_rays.get_children():
			var r: RayCast = ray
			if r.is_colliding():
				var c = r.get_collider()
				var direction: Vector3 = Vector3.ZERO
				if c.is_in_group("Spring"):
					entity.boost_direction = r.get_collision_normal() * c.get_parent().spring_power
				elif c.is_in_group("Booster"):
					entity.boost_direction = entity.move_direction.normalized()
				elif entity.boost_direction != Vector3.ZERO:
					entity.boost_direction = Vector3.ZERO

func is_on_surface() -> bool:
	if entity.surface_rays:
		for ray in entity.surface_rays.get_children():
			var r: RayCast = ray
			if r.is_colliding():
				if !r.get_collider().is_in_group("liquid"):
					return true
	return false
