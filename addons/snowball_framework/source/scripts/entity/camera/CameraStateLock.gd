class_name CameraStateLock
extends CameraStateMain

export var track_speed: int = 10

func enter() -> void:
	print("Camera State: LOCKED")
	entity.set_collision_mask_bit(2, false)
	entity.set_collision_mask_bit(3, false)
	entity.anim_tween.interpolate_property(entity.lens, "fov", entity.lens.fov, 35, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func physics_process(delta: float) -> int:
	if target_controlled():
		return State.ORBI
	if is_instance_valid(SB.prev_controlled):
		entity.rotation = lerp(entity.rotation, entity.target.rotation, track_speed * delta)
		entity.translation = lerp(entity.translation, entity.target.translation, track_speed * delta)
	return State.NULL

func exit() -> void:
	entity.set_collision_mask_bit(2, true)
	entity.set_collision_mask_bit(3, true)
