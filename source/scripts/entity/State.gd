class_name StateMain
extends Node

var entity: Entity = null

func print_state_name(state_names: Array, state: int) -> void:
	print(entity.get_entity_identity().get_entity_name() + "'s state is " + state_names[state])

func get_surface_normal(raw: bool = false) -> Vector3:
	var surface_normal = Vector3.ZERO
	var norm_avg = Vector3.ZERO
	var rays_colliding := 0
	for ray in entity.surface_rays.get_children():
		var r : RayCast = ray
		if r.is_colliding():
			if !raw:
				if r.get_collision_normal().y == -180 or !r.get_collider().is_in_group("slippery"):
					rays_colliding += 1
					norm_avg += r.get_collision_normal()
			else:
				rays_colliding += 1
				norm_avg += r.get_collision_normal()
	if norm_avg:
		surface_normal = norm_avg / rays_colliding
	else:
		surface_normal = Vector3.UP
	return surface_normal

func set_movement(delta: float, speed_modifier: float = 1.0, turn_modifier: float = 1.0, lerp_speed: float = 20) -> void:
	var modified_input_direction: Vector3 = (Vector3(entity.input_direction.x * turn_modifier, 0, entity.input_direction.y) * 1.6 * speed_modifier).rotated(Vector3.UP, SnailQuest.get_camera().get_global_rotation().y)
	entity.move_direction = lerp(modified_input_direction, entity.move_direction, lerp_speed * delta) * 1.75
	if entity.mirrored_movement:
		entity.move_direction = -entity.move_direction

	if entity.move_direction != Vector3.ZERO:
		entity.facing_angle = atan2(-entity.move_direction.x, -entity.move_direction.z)
	entity.rotation.y = lerp_angle(entity.rotation.y, entity.facing_angle, 12 * delta)

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
