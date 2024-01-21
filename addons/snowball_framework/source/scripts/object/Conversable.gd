class_name Conversable
extends Interactable

export var bubble_type: String

func trigger_dialog() -> void:
	if dialog != null:
		show_dialog_balloon("opener", dialog)
	else:
		show_dialog_balloon("opener", fallback)
	yield(DialogueManager, "dialogue_finished")
	dialog_end()
	emit_signal("interaction_ended")

func show_dialog_balloon(title: String, local_resource: DialogueResource = null, extra_game_states: Array = []) -> void:
	var dialog_line = yield(DialogueManager.get_next_dialogue_line(title, local_resource, extra_game_states), "completed")
	if dialog_line != null:
		var b
		if bubble_type:
			b = bubble_type
		else:
			b = "res://addons/dialogue_manager/example_balloon/example_balloon.tscn"
		var balloon = load(b).instance()
		balloon.dialogue_line = dialog_line
		get_tree().current_scene.add_child(balloon)
		show_dialog_balloon(yield(balloon, "actioned"), local_resource, extra_game_states)

func dialog_end() -> void:
	pass
