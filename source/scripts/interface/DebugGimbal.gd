extends Position3D

func _physics_process(delta: float) -> void:
	if SnailQuest.get_controlled():
		set_global_translation(SnailQuest.get_controlled().get_global_translation())
#		if "modified_input_direction" in SnailQuest.get_controlled():
#			set_global_rotation(SnailQuest.get_controlled().move_direction.rotated(Vector3.UP, deg2rad(45)))

