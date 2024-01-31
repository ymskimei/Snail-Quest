class_name CameraStateMain
extends Node

var sensitivity: float = 1

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

func states_unhandled_input(_event: InputEvent) -> int:
	return State.NULL

func states_physics_process(_delta: float) -> int:
	return State.NULL

func target_controlled() -> bool:
	if entity.target == SB.controlled:
		return true
	else:
		return false

func is_inverted(is_y: bool = false) -> bool:
	if is_y:
		return SB.game.interface.options.get_invert_vertical()
	else:
		return SB.game.interface.options.get_invert_horizontal()

func tween_cam_pan(arm: float, lens: float) -> void:
	entity.anim_tween.interpolate_value(entity, "rotation:x", arm, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_value(entity.lens, "rotation:x", lens, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.play()

func tween_cam_rotate(ease_type: int) -> void:
	var adjusted_rot = entity.rotation.y + wrapf(target_rot - entity.rotation.y, -PI, PI)
	entity.anim_tween.interpolate_value(entity, "rotation:y", adjusted_rot, 0.5, Tween.TRANS_EXPO, ease_type)
	entity.anim_tween.play()
	await entity.anim_tween.tween_completed
	rotation_complete = true

func exit() -> void:
	pass
