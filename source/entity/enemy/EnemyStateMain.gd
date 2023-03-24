class_name EnemyStateMain
extends Node

var entity: EnemyParent

var x_location = rand_range(-360, 360)
var z_location = rand_range(-360, 360)
var rot_speed = 0.05

enum State {
	NULL,
	WANDER,
	MOVE,
	SEEK,
	LOOK
}

func enter() -> void:
	pass

func physics_process(delta: float) -> int:
	apply_gravity(delta)
#	update_snap_vector()
	return State.NULL

func exit() -> void:
	pass

func apply_gravity(delta):
	entity.velocity.y += -entity.gravity * delta
	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)

func update_snap_vector():
	entity.snap_vector = -entity.get_floor_normal() if entity.is_on_floor() else Vector3.DOWN
