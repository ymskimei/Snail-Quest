extends EnemyStateMain

func enter() -> void:
	print("Enemy State: MOVE")

func physics_process(delta: float) -> int:
	.physics_process(delta)
	rot_speed = 0.02
	var global_pos = entity.global_transform.origin
	var w_transform = entity.global_transform.looking_at(Vector3(x_location, global_pos.y, z_location), Vector3.UP)
	var w_rotation = Quat(entity.global_transform.basis).slerp(Quat(w_transform.basis), rot_speed)
	entity.global_transform = Transform(Basis(w_rotation), global_pos)
	if entity.start_move == true:
		var velocity = entity.global_transform.basis.z.normalized() * entity.idle_speed * delta
		entity.move_and_collide(-velocity)
	if entity.target_near:
		return State.SEEK
	return State.NULL

#	if harass == true:
#		if entity.target_location != null:
#			return State.FOLLOW
#	elif player_escape == false:
