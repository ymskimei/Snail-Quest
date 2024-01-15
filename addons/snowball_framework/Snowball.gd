tool
extends EditorPlugin

const sb: String = "res://addons/snowball_framework/source/scenes/sb.tscn"

func _enter_tree() -> void:
	add_autoload_singleton("SB", sb)

func _exit_tree() -> void:
	remove_autoload_singleton("SB")
