class_name EnemyStateMain
extends Node

var entity : EnemyParent

var look_dir : float
var target_distance : float
var target_loc : Vector3
var snap_vector = Vector3.ZERO

var state_done : bool
var can_chase : bool

enum State {
	NULL,
	WAIT,
	IDLE,
	MOVE,
	AGRO,
	TARG,
	JUMP,
	FALL
}

func enter() -> void:
	look_dir = entity.rotation.y

func physics_process(delta: float) -> int:
	check_target_loc()
	return State.NULL

func apply_gravity(delta):
	entity.velocity.y += -entity.gravity * delta
	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)
	entity.velocity = entity.move_and_slide_with_snap(entity.velocity, snap_vector, Vector3.UP, true)

func apply_movement(delta, speed):
	var current = entity.transform.origin
	var next = entity.navi_agent.get_next_location()
	var velocity = (Vector3(next.x, current.y, next.z) - current).normalized() * delta * (entity.speed * speed)
	entity.move_and_collide(velocity)

func rotate():
	look_dir = entity.rotation.y + deg2rad((randi() % 270) - 135)

func check_target_loc():
	target_distance = entity.target.get_global_translation().distance_to(entity.get_global_translation())
	target_loc = entity.target.transform.origin

func chase_locked():
	if target_distance >= 4:
		can_chase = true
	else:
		can_chase = false

func exit() -> void:
	pass
