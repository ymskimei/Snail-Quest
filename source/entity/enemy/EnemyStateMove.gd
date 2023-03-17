extends EnemyStateMain

func enter() -> void:
	print("Enemy State: MOVE")

func physics_process(delta: float) -> int:
	rot_speed = 0.02

	var global_pos = enemy.global_transform.origin
	var w_transform = enemy.global_transform.looking_at(Vector3(x_location, global_pos.y, z_location), Vector3.UP)
	var w_rotation = Quat(enemy.global_transform.basis).slerp(Quat(w_transform.basis), rot_speed)
	enemy.global_transform = Transform(Basis(w_rotation), global_pos)
	if enemy.start_move == true:
		var velocity = enemy.global_transform.basis.z.normalized() * enemy.idle_speed * delta
		enemy.move_and_collide(-velocity)
	if enemy.target_near:
		return State.SEEK
	return State.NULL

#	if harass == true:
#		if enemy.target_location != null:
#			return State.FOLLOW
#	elif player_escape == false:
