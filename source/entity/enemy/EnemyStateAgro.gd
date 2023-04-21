extends EnemyStateMain

var look_dir
var timer = Timer.new()

func enter():
	print("Enemy State: AGRO")
	entity.anim.play("PawnIdle")
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)
	timer.wait_time = randi() % 5 + 1
	timer.start()

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	MathHelper.slerp_look_at(entity, Vector3(target_loc.x, entity.transform.origin.y, target_loc.z), 0.1)
	if can_chase:
		return State.TARG
	if !entity.target_seen:
		return State.IDLE
	return State.NULL
