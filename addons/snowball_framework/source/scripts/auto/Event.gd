extends Node

export var dialog_bubble: PackedScene

func initiate_dialog(skin: Resource, array: Resource) -> void:
	var bubble = dialog_bubble.instance()
	if skin:
		bubble.dialog_skin = skin
	if array:
		bubble.dialog_array = array
	add_child(bubble)
