class_name CameraStateMain
extends Node

var camera: PrimaryCamera
var rotation: Vector2
var velocity: Vector2
var controller_detected = false

export var sensitivity = 10
export var rotation_speed = 10
export var follow_speed = 3

enum State {
	NULL,
	ORBIT,
	LOCK,
	LOOK
}

func enter() -> void:
	pass

func input(_event: InputEvent) -> int:
	return State.NULL

func process(_delta: float) -> int:
	return State.NULL

func physics_process(_delta: float) -> int:
	return State.NULL

func exit() -> void:
	pass
