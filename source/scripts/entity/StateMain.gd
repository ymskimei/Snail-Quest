class_name StateMain
extends Node

var climbing_normal: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO

var is_on_floor: bool

func set_gravity(ent: Entity, state: PhysicsDirectBodyState, can_stick: bool = false) -> void:
	if can_stick:
		var norm_avg = Vector3.ZERO
		var rays_colliding := 0
		for ray in ent.climbing_rays.get_children():
			var r : RayCast = ray
			if r.is_colliding():
				rays_colliding += 1
				norm_avg += r.get_collision_normal()
		if norm_avg:
			climbing_normal = norm_avg / rays_colliding
		else:
			climbing_normal = Vector3.UP
		if rays_colliding >= 1:
			is_on_floor = true
		else:
			is_on_floor = false
	else:
		climbing_normal = Vector3.UP
	ent.global_transform = MathHelper.apply_surface_align(ent.global_transform, climbing_normal)
	state.add_central_force(50 * -climbing_normal)

func get_joy_input(ent: Entity) -> Vector3:
	var input = ent.input
	input.x = Input.get_action_strength("joy_left") - Input.get_action_strength("joy_right")
	input.z = Input.get_action_strength("joy_up") - Input.get_action_strength("joy_down")
	var input_length = input.length()
	if input_length > 1:
		input /= input_length
	return input

func apply_movement(ent: Entity, state: PhysicsDirectBodyState, multiplier: float, roll: bool = false) -> void:
	if ent.controllable:
		direction = -get_joy_input(ent).rotated(Vector3.UP, ent.cam.rotation.y)
		direction = direction.rotated(Vector3.LEFT, -ent.rotation.x).rotated(Vector3.UP, -ent.rotation.y)
		if direction != Vector3.ZERO:
			if roll:
				state.add_force((ent.speed * multiplier) * direction, -direction)
			else:
				state.add_central_force((ent.speed * multiplier) * direction)
				ent.skeleton.rotation.y = lerp_angle(ent.skeleton.rotation.y, atan2(-direction.x, -direction.z), 0.1)
