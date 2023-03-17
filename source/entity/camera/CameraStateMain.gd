class_name CameraStateMain
extends Node

var entity: MainCamera
var rotation: Vector2
var velocity: Vector2
var controller : bool

export var sensitivity = 10

enum State {
	NULL,
	ORBIT,
	LOOK,
	TARGET
}

func enter() -> void:
	pass

func input(_event: InputEvent) -> int:
	return State.NULL

func physics_process(_delta: float) -> int:
	return State.NULL

func exit() -> void:
	pass
