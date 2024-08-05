extends SnailState

var shell: RigidBody

func enter() -> void:
	print_state_name(STATE_NAMES, State.ROLL)

	entity.anim_states.travel("SnailRoll")

	var queue_timer = Timer.new()
	queue_timer.set_wait_time(0.2)
	queue_timer.one_shot = true
	queue_timer.connect("timeout", self, "_on_queue_timeout")
	add_child(queue_timer)
	queue_timer.start()

	shell = Utility.kinematic_to_physics_body(entity)
	shell.set_collision_layer_bit(3, false)
	shell.set_collision_layer_bit(0, true)
	shell.is_in_shell = true
	shell.input_direction = entity.input_direction * 1.5

func _on_queue_timeout() -> void:
	entity.get_parent().add_child(shell)
	shell.set_global_translation(entity.get_global_translation())
	shell.set_global_rotation(Vector3(0, entity.get_rotation_degrees().y, 0))

	SnailQuest.set_controlled(shell)

	entity.queue_free()
