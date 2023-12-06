class_name CameraStateLock
extends CameraStateMain

export var follow_speed: int = 10

func enter() -> void:
	print("Camera State: LOCKED")
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, 35, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, 1, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func physics_process(delta: float) -> int:
	if is_instance_valid(entity.lock_target):
		var targ: Spatial = entity.lock_target
		if "camera_target_proxy" in entity.lock_target:
			if entity.lock_target.camera_target_proxy != null:
				targ = entity.lock_target.camera_target_proxy
		#MathHelper.slerp_look_at(entity.camera_lens, targ.translation, follow_speed * delta)
		entity.rotation = lerp(entity.rotation, targ.rotation, follow_speed * delta)
		entity.translation = lerp(entity.translation, targ.translation, follow_speed * delta)
		if !entity.lock_to_point:
			return State.ORBI
	else:
		return State.ORBI
	return State.NULL

func exit() -> void:
	pass
