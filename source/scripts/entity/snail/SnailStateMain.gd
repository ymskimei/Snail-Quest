class_name SnailStateMain
extends StateMain

var input_up: int = 0
var input_down: int = 0
var input_left: int = 0
var input_right: int = 0

var jump_combo: int = 0

var shell_jumped: bool = false
var previous_swing: bool = false
var action_combat_held: bool = false

var input_timer: Timer = Timer.new()
var jump_combo_timer: Timer = Timer.new()

enum State {
	NULL,
	IDLE,
	MOVE,
	JUMP,
	FALL,
	HIDE,
	ROLL,
	DODG,
	HANG,
	PUSH
}

func enter() -> void:
	pass

func _ready():
	input_timer.set_one_shot(true)
	input_timer.set_wait_time(0.5)
	input_timer.connect("timeout", self, "on_input_timer")
	jump_combo_timer.set_one_shot(true)
	jump_combo_timer.set_wait_time(0.5)
	jump_combo_timer.connect("timeout", self, "on_jump_combo_timer")
	add_child(input_timer)
	add_child(jump_combo_timer)
	return State.NULL

func unhandled_input(_event: InputEvent) -> int:
	return State.NULL

func physics_process(_delta: float) -> int:
#	apply_aim_cursor()
	if is_on_floor():
		shell_jumped = false
	return State.NULL

func integrate_forces(state: PhysicsDirectBodyState) -> int:
	set_gravity(state)
	apply_rotation()
	return State.NULL

func roll(event) -> bool:
	if event.is_action_pressed("joy_up"):
		input_up += 1
		input_timer.start()
		if input_up >= 2:
			return true
	elif event.is_action_pressed("joy_down"):
		input_down += 1
		input_timer.start()
		if input_down >= 2:
			return true
	elif event.is_action_pressed("joy_left"):
		input_left += 1
		input_timer.start()
		if input_left >= 2:
			return true
	elif event.is_action_pressed("joy_right"):
		input_right += 1
		input_timer.start()
		if input_right >= 2:
			return true
	return false

func on_input_timer() -> void:
	input_up = 0
	input_down = 0
	input_left = 0
	input_right = 0
	if Input.is_action_pressed("action_combat"):
		action_combat_held = true
	else:
		action_combat_held = false

func on_jump_combo_timer() -> void:
	jump_combo = 0

#func apply_aim_cursor() -> void:
#	if entity.targeting and entity.target_found or entity.cursor_activated:
#		var cursor = entity.cursor.instance()
#		if is_instance_valid(entity.get_parent().get_node_or_null("AimCursor")):
#			entity.get_parent().get_node("AimCursor").queue_free()
#			entity.cursor_activated = false
#		else:
#			cursor.set_name("AimCursor")
#			entity.get_parent().add_child(cursor)
#			entity.cursor_activated = true

func needle() -> void:
	var needle = entity.holding_point.get_node_or_null("Needle")
	if is_instance_valid(needle):
#		if Input.is_action_just_released("action_combat"):
#			if previous_swing:
#				entity.animator.play("PlayerSwingDefault")
#				needle.swing_left()
#				previous_swing = false
#			else:
#				entity.animator.play_backwards("PlayerSwingDefault")
#				needle.swing_right()
#				previous_swing = true
#		if entity.targeting:
#			needle.directionaaal_swing()
		if Input.is_action_just_pressed("action_combat"):
			#entity.can_move = false
			entity.cursor_activated = true
		if Input.is_action_just_released("action_combat"):
			#entity.can_move = true
			entity.cursor_activated = false
#			var last_pos = needle.global_transform
#			entity.attach_point.remove_child(needle)
#			entity.get_parent().add_child(needle)
#			var detatched_needle = entity.get_parent().get_node_or_null("Needle")
#			detatched_needle.global_transform = last_pos
#			#var throw_dir = target_position - player_position
#			var throw_dir = entity.transform.basis.xform(Vector3(0, 0, -1).normalized())
#			detatched_needle.throw(throw_dir)

func mallet() -> void:
	var mallet = entity.holding_point.get_node_or_null("Mallet")
	if is_instance_valid(mallet):
		if Input.is_action_just_pressed("action_combat"):
			input_timer.start()
			yield(input_timer, "timeout")
			if action_combat_held == true:
				#entity.can_move = false
				entity.animator.play("PlayerSlamDefault")
				mallet.slam()
		elif Input.is_action_just_released("action_combat"):
			#entity.can_move = true
			entity.animator.play("PlayerIdleDefault")
			mallet.end_slam()
		if Input.is_action_just_released("action_combat") and action_combat_held == false:
			if entity.animator.current_animation != "PlayerSwingDefault":
				print("true")
				if previous_swing:
					entity.animator.play_backwards("PlayerSwingDefault")
					mallet.swing_left()
					yield(entity.animator, "animation_finished")
					previous_swing = false
				else:
					entity.animator.play("PlayerSwingDefault")
					mallet.swing_right()
					yield(entity.animator, "animation_finished")
					previous_swing = true

func exit() -> void:
	pass
