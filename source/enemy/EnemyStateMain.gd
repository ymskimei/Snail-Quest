class_name EnemyStateMain
extends Node

var enemy: EnemyParent

var x_location = rand_range(-360, 360)
var z_location = rand_range(-360, 360)
var rot_speed = 0.05

enum State {
	NULL,
	MOVE,
	SEEK,
	LOOK
}

func enter() -> void:
	pass

func physics_process(_delta: float) -> int:
	return State.NULL

func exit() -> void:
	pass
