class_name StateMain
extends Node

var entity: Entity

var climbing_normal: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO

func set_gravity(state: PhysicsDirectBodyState) -> void:
	var can_climb: bool = false
	if is_instance_valid(entity.climbing_rays):
		var norm_avg = Vector3.ZERO
		var rays_colliding := 0
		for ray in entity.climbing_rays.get_children():
			var r : RayCast = ray
			if r.is_colliding():
				if r.get_collider().is_in_group("climbable"):
					can_climb = true
					rays_colliding += 1
					norm_avg += r.get_collision_normal()
		if !norm_avg or !can_climb:
			climbing_normal = Vector3.UP
		else:
			climbing_normal = norm_avg / rays_colliding
	else:
		climbing_normal = Vector3.UP
	entity.global_transform = MathHelper.apply_surface_align(entity.global_transform, climbing_normal)
	state.add_central_force(50 * -climbing_normal)

func get_joy_input() -> Vector3:
	var input = entity.input
	input.x = Input.get_action_strength("joy_left") - Input.get_action_strength("joy_right")
	input.z = Input.get_action_strength("joy_up") - Input.get_action_strength("joy_down")
	var input_length = input.length()
	if input_length > 1:
		input /= input_length
	return input

func apply_movement(state: PhysicsDirectBodyState, multiplier: float, roll: bool = false) -> void:
	direction = -get_joy_input().rotated(Vector3.UP, entity.cam.rotation.y)
	direction = direction.rotated(Vector3.LEFT, -entity.rotation.x).rotated(Vector3.RIGHT, -entity.rotation.y)
	if direction != Vector3.ZERO:
		if roll:
			state.add_force((entity.speed * multiplier) * direction, -direction)
		else:
			state.add_central_force((entity.speed * multiplier) * direction)
			entity.skeleton.rotation.y = lerp_angle(entity.skeleton.rotation.y, atan2(-direction.x, -direction.z), 0.1)

func is_on_floor() -> bool:
	if is_instance_valid(entity.climbing_rays):
		for ray in entity.climbing_rays.get_children():
			var r : RayCast = ray
			if r.is_colliding():
				return true
	elif is_instance_valid(entity.floor_checker):
		if entity.floor_checker.is_colliding():
			return true
	return false
