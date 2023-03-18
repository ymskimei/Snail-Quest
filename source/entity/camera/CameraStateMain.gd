class_name CameraStateMain
extends Node

var entity: MainCamera
var rotation: Vector2
var velocity: Vector2
var controller : bool

export var sensitivity = 10

enum State {
	NULL,
	ORBI,
	TARG,
	ISOM,
	LOOK
}

func enter() -> void:
	pass

func input(_event: InputEvent) -> int:
	return State.NULL

func physics_process(_delta: float) -> int:
	return State.NULL

func tween_cam_pan(arm, lens):
	entity.anim_tween.interpolate_property(entity, "rotation:x", entity.rotation.x, arm, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity.camera_lens, "rotation:x", entity.camera_lens.rotation.x, lens, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func exit() -> void:
	pass
