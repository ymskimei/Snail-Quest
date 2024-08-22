class_name SnailState
extends StateMain

var input_up: int = 0
var input_down: int = 0
var input_left: int = 0
var input_right: int = 0

var action_combat_held: bool = false

var input_timer: Timer = Timer.new()

enum State {
	NULL,
	FALL,
	IDLE,
	MOVE,
	JUMP,
	HIDE,
	ROLL,
	JRLL,
	GPND,
	SLID,
	SPIN
}

const STATE_NAMES: Array = [
	"NULL",
	"FALL",
	"IDLE",
	"MOVE",
	"JUMP",
	"HIDE",
	"ROLL",
	"JRLL",
	"GPND",
	"SLID",
	"SPIN"
]

func roll(event) -> bool:
	if event.is_action_pressed(Device.stick_main_up):
		input_up += 1
		input_timer.start()
		if input_up >= 2:
			return true
	elif event.is_action_pressed(Device.stick_main_down):
		input_down += 1
		input_timer.start()
		if input_down >= 2:
			return true
	elif event.is_action_pressed(Device.stick_main_left):
		input_left += 1
		input_timer.start()
		if input_left >= 2:
			return true
	elif event.is_action_pressed(Device.stick_main_right):
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
#	if Input.is_action_pressed(Device.action_alt):
#		action_combat_held = true
#	else:
#		action_combat_held = false
