class_name EnemyStateMain
extends Node

var entity: EnemyParent

var x_location = rand_range(-360, 360)
var z_location = rand_range(-360, 360)
var rot_speed = 0.05

enum State {
	NULL,
	WAND,
	MOVE,
	SEEK,
	LOOK,
	BATT
}

func enter() -> void:
	pass

func physics_process(delta: float) -> int:
#	update_snap_vector()
	return State.NULL

func apply_gravity(delta):
	entity.velocity.y += -entity.gravity * delta
	entity.velocity.y = clamp(entity.velocity.y, -entity.gravity, entity.jump)

func exit() -> void:
	pass
