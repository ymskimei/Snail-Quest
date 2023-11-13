class_name Interactable
extends RigidBody

export(Resource) var dialog

onready var anim: AnimationPlayer = $AnimationPlayer
onready var anim_tween: Tween = $Tween

var character: bool

signal interaction_ended

func get_interaction_text():
	return "interact"

func trigger_dialog() -> void:
	show_dialog_balloon("opener", dialog)
	yield(DialogueManager, "dialogue_finished")
	emit_signal("interaction_ended")

func show_dialog_balloon(title: String, local_resource: DialogueResource = null, extra_game_states: Array = []) -> void:
	var dialog_line = yield(DialogueManager.get_next_dialogue_line(title, local_resource, extra_game_states), "completed")
	if dialog_line != null:
		var balloon = preload("res://source/scenes/gui/gui_dialog_balloon.tscn").instance()
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
		set_global_rotation(Vector3(0, deg2rad(MathHelper.cardinal_to_degrees(angle)), 0))

func is_controlled() -> bool:
	if GlobalManager.controllable == self:
		return true
	return false
