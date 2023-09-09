class_name CameraStateMain
extends Node

export var sensitivity: int = 10

var entity: MainCamera
var rotation: Vector2
var velocity: Vector2

var target_rot: float

var controller: bool
var zoomed_out: bool
var rotation_complete: bool

enum State {
	NULL,
	FREE,
	ORBI,
	TARG,
	ISOM,
	LOOK,
	VEHI,
	LOCK
}

func enter() -> void:
	pass

func input(_event: InputEvent) -> int:
	return State.NULL

func physics_process(_delta: float) -> int:
	return State.NULL

func tween_cam_pan(arm: float, lens: float) -> void:
	entity.anim_tween.interpolate_property(entity, "rotation:x", entity.rotation.x, arm, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity.camera_lens, "rotation:x", entity.camera_lens.rotation.x, lens, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func tween_cam_rotate(ease_type: int) -> void:
	var adjusted_rot = entity.rotation.y + wrapf(target_rot - entity.rotation.y, -PI, PI)
	entity.anim_tween.interpolate_property(entity, "rotation:y", entity.rotation.y, adjusted_rot, 0.5, Tween.TRANS_EXPO, ease_type)
	entity.anim_tween.start()
	yield(entity.anim_tween, "tween_completed")
	rotation_complete = true

func exit() -> void:
	pass
