extends Node

var current_state: EnemyStateMain

onready var states = {
	EnemyStateMain.State.MOVE: $Move,
	EnemyStateMain.State.SEEK: $Seek,
	EnemyStateMain.State.LOOK: $Look
}

func ready(enemy: EnemyParent) -> void:
	for child in get_children():
		child.enemy = enemy
	change_state(EnemyStateMain.State.MOVE)

func physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)
	if new_state != EnemyStateMain.State.NULL:
		change_state(new_state)

func change_state(new_state: int) -> void:
	if current_state:
		current_state.exit()
	current_state = states[new_state]
	current_state.enter()
