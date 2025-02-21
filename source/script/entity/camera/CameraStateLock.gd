class_name CameraStateLock
extends CameraStateMain

export var track_speed: float = 6
var new_rotation: Vector3 = Vector3.ZERO

func enter() -> void:
	print("Camera State: LOCKED")
	entity.collision.set_disabled(true)

	if is_instance_valid(entity.override):
		if entity.target is Position3D:
			new_rotation = entity.target.get_global_rotation()
		else:
			new_rotation = Vector3(entity.target.get_global_rotation().x + deg2rad(-10), entity.target.get_global_rotation().y + deg2rad(180), entity.target.get_global_rotation().z)
	elif is_instance_valid(entity.positioner) and is_instance_valid(SnailQuest.get_prev_controlled()):
		new_rotation = SnailQuest.get_prev_controlled().get_global_rotation()

	if is_instance_valid(entity.override):
		entity.spring_length = 5

	entity.anim_tween.interpolate_property(entity.lens, "fov", entity.lens.fov, 45, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	#entity.anim_tween.interpolate_property(entity, "spring_length", entity.spring_length, new_spring_length, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entity.anim_tween.start()

func physics_process(delta: float) -> int:
	if !is_instance_valid(entity.override) and !is_instance_valid(entity.positioner):
		return State.ORBI
	entity.rotation.x = lerp(entity.rotation.x, new_rotation.x, track_speed * delta)
	entity.rotation.y = lerp_angle(entity.rotation.y, new_rotation.y, track_speed * delta)
	entity.rotation.z = lerp(entity.rotation.z, new_rotation.z, track_speed * delta)
	entity.translation = lerp(entity.translation, entity.target.global_translation, track_speed * delta)
	return State.NULL

func exit() -> void:
	entity.collision.set_disabled(false)
