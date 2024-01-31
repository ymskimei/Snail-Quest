@tool
extends EditorPlugin

const sb: String = "res://addons/snowball_framework/source/scenes/auto/sb.tscn"
const utility: String = "res://addons/snowball_framework/source/scenes/auto/utility.tscn"
const data: String = "res://addons/snowball_framework/source/scenes/auto/data.tscn"
const device: String = "res://addons/snowball_framework/source/scenes/auto/device.tscn"
const audio: String = "res://addons/snowball_framework/source/scenes/auto/audio.tscn"
const item: String = "res://addons/snowball_framework/source/scenes/auto/item.tscn"

func _enter_tree() -> void:
	add_autoload_singleton("SB", sb)
	add_autoload_singleton("Utility", utility)
	add_autoload_singleton("Data", data)
	add_autoload_singleton("Device", device)
	add_autoload_singleton("Audio", audio)
	add_autoload_singleton("Item", item)

func _exit_tree() -> void:
	remove_autoload_singleton("SB")
	remove_autoload_singleton("Utility")
	remove_autoload_singleton("Data")
	remove_autoload_singleton("Device")
	remove_autoload_singleton("Audio")
	remove_autoload_singleton("Item")
