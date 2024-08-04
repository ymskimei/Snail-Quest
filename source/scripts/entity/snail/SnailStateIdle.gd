extends SnailState

func enter() -> void:
	print_state_name(STATE_NAMES, State.IDLE)

	entity.anim_states.travel("SnailIdle")
	var amount: float = 0
	match entity.get_entity_identity().get_entity_personality():
		1:
			amount = 1.0
		2:
			amount = -1.0
		_:
			amount = 0.0
	entity.anim_tree.set("parameters/SnailIdle/Blend3/blend_amount", amount)

	entity.move_momentum = 0
	entity.boosting = false

func unhandled_input(event: InputEvent) -> int:
	if event.is_action_pressed(Device.action_main):
		return State.JUMP

	if event.is_action_pressed(Device.action_alt):
		return State.SPIN

	if event.is_action_pressed(Device.trigger_right):
		return State.HIDE

	return State.NULL

func physics_process(delta: float) -> int:
	set_movement(delta)

	if !is_on_surface():
		return State.FALL

	if entity.move_direction.length() > 0.01:
		return State.MOVE

	if entity.jump_in_memory or entity.boost_direction.length() > 0.01:
		return State.JUMP

	## Temporary ##

	var music_players: Array = Utility.get_group_by_nearest(entity, "music_player")
	for i in music_players:
		if entity.get_global_translation().distance_to(i.get_global_translation()) <= 5:
			entity.anim_states.travel("SnailGrooving")
			entity.anim_tree.set("parameters/SnailGrooving/TimeScale/scale", i.bpm / 120)

	return State.NULL

func exit() -> void:
	pass

