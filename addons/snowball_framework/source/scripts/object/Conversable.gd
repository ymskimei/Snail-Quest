class_name Conversable
extends Interactable

@export var bubble_type: String

func trigger_dialog() -> void:
	if dialog != null:
		show_dialog_balloon("opener", dialog)
	else:
		show_dialog_balloon("opener", fallback)
	await DialogueManager.dialogue_finished
	dialog_end()
	emit_signal("interaction_ended")

func show_dialog_balloon(title: String, local_resource: DialogueResource = null, extra_game_states: Array = []) -> void:
	var dialog_line = await DialogueManager.get_next_dialogue_line(local_resource, title, extra_game_states)
	if dialog_line.completed != null:
		var b
		if bubble_type:
			b = bubble_type
		else:
			b = "res://addons/dialogue_manager/example_balloon/example_balloon.tscn"
		var balloon = load(b).instantiate()
		balloon.dialogue_line = dialog_line
		get_tree().current_scene.add_child(balloon)
		show_dialog_balloon(await balloon.actioned, local_resource, extra_game_states)

func dialog_end() -> void:
	pass
