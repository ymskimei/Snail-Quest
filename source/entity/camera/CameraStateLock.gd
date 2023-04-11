class_name CameraStateLock
extends CameraStateMain

export var offset = Vector3(0, 1, 0)
export var follow_speed = 4

func enter() -> void:
	print("Camera State: LOCKED")
	entity.anim_tween.interpolate_property(entity.camera_lens, "fov", entity.camera_lens.fov, 20, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, 17, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func physics_process(delta):
	if is_instance_valid(entity.lock_target):
		MathHelper.slerp_look_at(entity.camera_lens, (entity.player.translation / 3) + Vector3(0, 2, 0), follow_speed * delta)
		entity.rotation = lerp(entity.rotation, entity.lock_target.rotation, follow_speed * delta)
		entity.translation = lerp(entity.translation, entity.lock_target.translation, follow_speed * delta)
		if !entity.lock_to_point:
			return State.ORBI
	else:
		return State.ORBI
	return State.NULL

func exit() -> void:
	pass
