extends EnemyStateMain

var mid_state = MidState.ATTACK

var timer = Timer.new()
var timer_set = false
var move_set = false
var look_dir

enum MidState {
	ATTACK, WAIT
}

func _ready():
	timer.one_shot = true
	timer.connect("timeout", self, "end_wait")
	add_child(timer)

func enter():
	print("Enemy State: BATTLE")
	mid_state = MidState.ATTACK

func physics_process(delta: float) -> int:
	.physics_process(delta)
	apply_gravity(delta)
	var target_distance = entity.target.get_global_translation().distance_to(entity.get_global_translation())
	var target_loc = entity.target.transform.origin
	MathHelper.slerp_look_at(entity, Vector3(target_loc.x, entity.transform.origin.y, target_loc.z), 0.1)
	if target_distance <= 4:
		mid_state = MidState.WAIT
	match (mid_state):
		MidState.ATTACK:
			entity.anim.play("PawnMove")
			if !move_set:
				var current_loc = entity.transform.origin
				entity.navi_agent.set_target_location(entity.target.transform.origin)
				move_set = true
				entity.navi_agent.connect("target_reached", self, "reset_move")
				print("test")
			else:
				move(delta)
		MidState.WAIT:
			move_set = false
			entity.anim.play("PawnIdle")
			if target_distance > 4:
				mid_state = MidState.ATTACK
	if !entity.target_seen:
		return State.WAND
	return State.NULL

func move(delta):
	var current = entity.transform.origin
	var next = entity.navi_agent.get_next_location()
	var velocity = (next - current).normalized() * delta * entity.speed
	entity.move_and_collide(velocity)
