extends EnemyStateMain

func enter() -> void:
	print("Enemy State: LOOK")

func physics_process(delta: float) -> int:
	var global_pos = entity.global_transform.origin
	var target_pos = entity.target.global_transform.origin
	var wtransform = entity.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
	var wrotation = Quat(entity.global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
	entity.global_transform = Transform(Basis(wrotation), global_pos)
	if !entity.is_on_floor():
		entity.rotate
		entity.move_and_collide(-entity.global_transform.basis.y.normalized() * entity.gravity * delta)
	if entity.escaped_yet:
		return State.MOVE
	return State.NULL
