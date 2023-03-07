extends Node

var current_state: CameraStateMain

onready var states = {
	CameraStateMain.State.ORBIT: $Orbit,
	CameraStateMain.State.LOOK: $Look,
	CameraStateMain.State.TARGET: $Target
}

func ready(camera: MainCamera) -> void:
	for child in get_children():
		child.camera = camera
	change_state(CameraStateMain.State.ORBIT)

func unhandled_input(event: InputEvent) -> void:
	var new_state = current_state.input(event)
	if new_state != CameraStateMain.State.NULL:
		change_state(new_state)

func physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)
	if new_state != CameraStateMain.State.NULL:
		change_state(new_state)

func change_state(new_state: int) -> void:
	if current_state:
		current_state.exit()
	current_state = states[new_state]
	current_state.enter()
