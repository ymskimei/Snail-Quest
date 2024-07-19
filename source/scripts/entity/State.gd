class_name StateMain
extends Node

var entity: Entity = null

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

func set_gravity(delta: float) -> void:
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	entity.move_and_slide_with_snap((gravity / 3 + entity.fall_momentum) * -get_surface_normal() * delta, Vector3.DOWN, Vector3.UP, true, 4, 0.785398, false)
	entity.global_transform.basis.y = get_surface_normal()
	entity.global_transform.basis.x = -entity.global_transform.basis.z.cross(get_surface_normal())
	entity.global_transform.basis = entity.global_transform.basis.orthonormalized()

func get_input(turn_modifier: float = 1.0, raw: bool = false) -> Vector3:
	if entity.can_be_controlled():
		var direction: Vector3 = Vector3.ZERO
		direction.x = Input.get_axis(Device.stick_main_left, Device.stick_main_right) * turn_modifier
		direction.z = Input.get_axis(Device.stick_main_up, Device.stick_main_down)
		if !raw:
			direction = direction * 1.8
		direction = direction.rotated(Vector3.UP, SnailQuest.get_camera().rotation.y)
		#direction = entity.global_transform.basis.xform(direction).normalized()
		return direction
	return Vector3.ZERO

func set_movement(delta: float, modifier: float = 1.0, control: bool = true, reverse: bool = false, turn_modifier: float = 1.0, slide_speed: int = 20) -> void:
	if control:
		var temp_input: Vector3 = get_input(turn_modifier)
		entity.direction = lerp(entity.direction, temp_input, slide_speed * delta)

	if entity.direction != Vector3.ZERO:
		var movement: Vector3 = (3.75 * modifier * entity.direction * delta)
		if reverse:
			movement = -movement
		entity.move_and_slide(movement * 45 * modifier, Vector3.UP, false, 4, deg2rad(75), false)

	for i in entity.get_slide_count():
		var c = entity.get_slide_collision(i)
		if c.collider is RigidBody:
			c.collider.apply_central_impulse(-c.normal * 2)

func boost_momentum() -> void:
	if entity.surface_rays:
		for ray in entity.surface_rays.get_children():
			var r: RayCast = ray
			if r.is_colliding():
				var c = r.get_collider()
				var direction: Vector3 = Vector3.ZERO
				if c.is_in_group("Spring"):
					entity.boost_momentum = r.get_collision_normal() * c.get_parent().spring_power
				elif c.is_in_group("Booster"):
					entity.boost_momentum = entity.direction.normalized()
				elif entity.boost_momentum != Vector3.ZERO:
					entity.boost_momentum = Vector3.ZERO

func set_rotation(delta: float, modifier: float = 1.0) -> void:
	if entity.direction != Vector3.ZERO:
		entity.facing = atan2(-entity.direction.x, -entity.direction.z)
	entity.rotation.y = lerp_angle(entity.rotation.y, entity.facing, 12 * modifier * delta)

func is_on_surface(down_only: bool = false) -> bool:
	if entity.surface_rays:
		for ray in entity.surface_rays.get_children():
			var r: RayCast = ray
			if down_only:
				if r.is_colliding() and r.get_collision_normal().y == 1.0 or entity.is_on_floor():
					return true
			elif r.is_colliding():
					return true
	return false
