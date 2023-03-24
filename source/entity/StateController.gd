extends Node

var current_state
var et


func ready(entity) -> void:
	et = entity
	for child in get_children():
		child.entity = entity
	change_state(1) # default state

func change_state(new_state: int) -> void:
	if current_state:
		current_state.exit()
	# Subtract 1 to account for NULL
	current_state = get_children()[new_state-1]
	current_state.enter()

# Passing methods
func physics_process(delta: float) -> void:
	if current_state.has_method("physics_process"):
		var new_state = current_state.physics_process(delta)
		if new_state != 0: # not null state
			change_state(new_state)

func unhandled_input(event: InputEvent) -> void:
	if current_state.has_method("input"):
		var new_state = current_state.input(event)
		if new_state != PlayerStateMain.State.NULL:
			change_state(new_state)
