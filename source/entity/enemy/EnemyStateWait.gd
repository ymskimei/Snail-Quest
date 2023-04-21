extends EnemyStateMain

var mid_state = MidState.WAIT

var timer = Timer.new()
var timer_set = false
var move_set = false
var look_dir

enum MidState {
	WAIT, IDLE, MOVE
}

func enter():
	print("Enemy State: WANDER")
	mid_state = MidState.WAIT

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	match (mid_state):
		MidState.WAIT:
			entity.anim.play("PawnIdle")
			mid_state = randi() % 3
		MidState.IDLE:
			return State.IDLE
		MidState.MOVE:
			return State.MOVE
	if entity.target_seen:
		return State.TARG
	return State.NULL
