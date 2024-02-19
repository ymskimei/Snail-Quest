class_name CameraStateLock
extends CameraStateMain

export var track_speed: int = 10

func enter() -> void:
	print("Camera State: LOCKED")
#	entity.collision.disabled = true
	entity.anim_tween.interpolate_property(entity.lens, "fov", entity.lens.fov, 35, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func physics_process(delta: float) -> int:
	if is_instance_valid(entity.override):
		entity.rotation = lerp(entity.rotation, entity.target.global_rotation, track_speed * delta)
	elif is_instance_valid(entity.positioner) and is_instance_valid(SB.prev_controlled):
		entity.rotation = lerp(entity.rotation, SB.prev_controlled.global_rotation, track_speed * delta)
	else:
		return State.ORBI
	entity.translation = lerp(entity.translation, entity.target.global_translation, track_speed * delta)
	return State.NULL

#func exit() -> void:
#	entity.collision.disabled = false
