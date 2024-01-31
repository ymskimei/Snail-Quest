class_name CameraStateLock
extends CameraStateMain

@export var track_speed: int = 10

func enter() -> void:
	print("Camera3D State: LOCKED")
	entity.collision.disabled = true
	entity.anim_tween.interpolate_value(entity.lens, "fov", 35, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_value(entity, "arm_length", 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.play()

func states_physics_process(delta: float) -> int:
	if is_instance_valid(entity.override):
		entity.rotation = lerp(entity.rotation, entity.target.global_rotation, track_speed * delta)
	elif is_instance_valid(entity.positioner) and is_instance_valid(SB.prev_controlled):
		entity.rotation = lerp(entity.rotation, SB.prev_controlled.global_rotation, track_speed * delta)
	else:
		return State.ORBI
	entity.position = lerp(entity.position, entity.target.global_position, track_speed * delta)
	return State.NULL

func exit() -> void:
	entity.collision.disabled = false
