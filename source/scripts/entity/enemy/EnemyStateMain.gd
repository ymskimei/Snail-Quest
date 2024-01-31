class_name EnemyStateMain
extends Node

var entity: Enemy

var look_dir: float
var target_distance: float
var target_loc: Vector3
var snap_vector: Vector3 = Vector3.ZERO

var state_done: bool
var can_chase: bool

enum State {
	NULL,
	IDLE,
	MOVE,
	AGRO,
	TARG,
	JUMP,
	FALL
}

func enter() -> void:
	look_dir = entity.rotation.y

func physics_process(_delta: float) -> int:
	check_target_loc()
	return State.NULL

#func apply_gravity(delta: float) -> void:
#	entity.velocity.y += -entity.gravity * delta
#	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)
#	entity.velocity = entity.move_and_slide_with_snap(entity.velocity, snap_vector, Vector3.UP, true)
#
#func apply_movement(delta: float, speed: int) -> void:
#	var current = entity.transform.origin
#	var next = entity.navi_agent.get_next_location()
#	var velocity = (Vector3(next.x, current.y, next.z) - current).normalized() * delta * (entity.speed * speed)
#	entity.move_and_collide(velocity)

func rotate() -> void:
	look_dir = entity.rotation.y + deg_to_rad((randi() % 270) - 135)

func check_target_loc() -> void:
	target_distance = entity.target.get_global_translation().distance_to(entity.get_global_translation())
	target_loc = entity.target.transform.origin

func chase_locked() -> void:
	if target_distance >= 4:
		can_chase = true
	else:
		can_chase = false

func exit() -> void:
	pass
