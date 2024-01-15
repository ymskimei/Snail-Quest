class_name Interactable
extends RigidBody

export(Resource) var dialog

onready var anim: AnimationPlayer = $AnimationPlayer

const fallback: DialogueResource = preload("res://assets/resource/dialog/error_fallback.tres")

var character: bool

signal interaction_ended

func get_interaction_text() -> String:
	return "interact"

func trigger_dialog() -> void:
	if is_instance_valid(dialog):
		show_dialog_balloon("opener", dialog)
	else:
		show_dialog_balloon("opener", fallback)
	yield(DialogueManager, "dialogue_finished")
	emit_signal("interaction_ended")

func show_dialog_balloon(title: String, local_resource: DialogueResource = null, extra_game_states: Array = []) -> void:
	var dialog_line = yield(DialogueManager.get_next_dialogue_line(title, local_resource, extra_game_states), "completed")
	if dialog_line != null:
		var balloon = preload("res://source/scenes/interface/menu_dialog.tscn").instance()
		balloon.dialogue_line = dialog_line
		get_tree().current_scene.add_child(balloon)
		show_dialog_balloon(yield(balloon, "actioned"), local_resource, extra_game_states)

func get_coords(raw: bool = false) -> Vector3:
	var x = global_transform.origin.x
	var y = global_transform.origin.y
	var z = global_transform.origin.z
	if !raw:
		x = round(x)
		y = round(y)
		z = round(z)
	var coords = [x, y, z]
	return coords

func set_coords(position: Vector3, angle: String = "Default") -> void:
	set_global_translation(position)
	if !angle == "Default":
		set_global_rotation(Vector3(0, deg2rad(SB.utility.cardinal_to_degrees(angle)), 0))

func is_controlled() -> bool:
	if SB.controllable == self:
		return true
	return false
