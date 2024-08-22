class_name Conversable
extends Interactable

var dialog_bubble: PackedScene = load("res://source/scene/dialog.tscn")

export var dialog_id: int

func interact() -> void:
	var bubble: CanvasLayer = dialog_bubble.instance()
	bubble.current_dialog_keys = dialog_fetcher()
	camera_override()
	if bubble.current_dialog_keys.size() > 0:
		add_child(bubble)
		bubble.connect("dialog_ended", self,"_dialog_end")
	else:
		_dialog_end()

func dialog_fetcher() -> Array:
	var dialog_array: Array = []
	var dialog_by_id: String = "DIALOG_%s_" % str(dialog_id)
	for n in 16:
		if Utility.tr_key_exists(dialog_by_id + str(n)):
			dialog_array.append(tr(dialog_by_id + str(n)))
	return dialog_array

func _dialog_end() -> void:
	SnailQuest.get_controlled().interacting = false
	camera_override(false)
