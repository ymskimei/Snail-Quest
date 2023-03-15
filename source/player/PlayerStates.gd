extends Node

var current_state: PlayerStateMain

onready var states = {
	PlayerStateMain.State.IDLE: $Idle,
	PlayerStateMain.State.MOVE: $Move,
	PlayerStateMain.State.FALL: $Fall,
	PlayerStateMain.State.JUMP: $Jump
}

func ready(player: Player) -> void:
	for child in get_children():
		child.player = player
	change_state(PlayerStateMain.State.IDLE)

func unhandled_input(event: InputEvent) -> void:
	var new_state = current_state.input(event)
	if new_state != PlayerStateMain.State.NULL:
		change_state(new_state)

func physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)
	if new_state != PlayerStateMain.State.NULL:
		change_state(new_state)

func process(delta: float) -> void:
	var new_state = current_state.process(delta)
	if new_state != PlayerStateMain.State.NULL:
		change_state(new_state)

func change_state(new_state: int) -> void:
	if current_state:
		current_state.exit()
	current_state = states[new_state]
	current_state.enter()
