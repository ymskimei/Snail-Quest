extends Node

var current_state: Node
var et: Spatial

func ready(entity: Spatial) -> void:
	et = entity
	for child in get_children():
		child.entity = entity
	change_state(1)

func change_state(new_state: int) -> void:
	if current_state:
		current_state.exit()
	if get_children().empty() == false:
		current_state = get_children()[new_state - 1]
		current_state.enter()

func input(event: InputEvent) -> void:
	if is_instance_valid(current_state):
		if current_state.has_method("input"):
			var new_state = current_state.input(event)
			if new_state != 0:
				change_state(new_state)

func unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(current_state):
		if current_state.has_method("unhandled_input"):
			var new_state = current_state.unhandled_input(event)
			if new_state != 0:
				change_state(new_state)

func process(delta: float) -> void:
	if is_instance_valid(current_state):
		if current_state.has_method("process"):
			var new_state = current_state.process(delta)
			if new_state != 0:
				change_state(new_state)

func physics_process(delta: float) -> void:
	if is_instance_valid(current_state):
		if current_state.has_method("physics_process"):
			var new_state = current_state.physics_process(delta)
			if new_state != 0:
				change_state(new_state)

func integrate_forces(state: PhysicsDirectBodyState) -> void:
	if is_instance_valid(current_state):
		if current_state.has_method("integrate_forces"):
			var new_state = current_state.integrate_forces(state)
			if new_state != 0:
				change_state(new_state)
