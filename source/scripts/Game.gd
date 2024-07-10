extends Node

onready var interface: Node = $Interface
onready var screen: Node = $Screen

var title = preload("res://source/scenes/interface/screen_title.tscn")
var data = preload("res://source/scenes/interface/screen_data.tscn")
var world = preload("res://source/scenes/world/world.tscn")

var cfg: String = "res://export_presets.cfg"

var info: Dictionary = {
	"title": ProjectSettings.get_setting("application/config/name"),
	"description": ProjectSettings.get_setting("application/config/description"),
	"version": "0.5.0-pre-alpha",
	"author": "Kaboodle"
}

func _ready():
	Auto.set_game(self)
	OS.set_window_title("Snail Quest " + info["version"] + " (DEBUG)")
	screen.add_child(title.instance())

func change_screen(new_scene: PackedScene):
	Auto.input.set_block_input(true)
	interface.transition.play("GuiTransitionFade")
	yield(interface.transition, "animation_finished")
	screen.get_child(0).queue_free()
	yield(screen.get_child(0), "tree_exited")
	screen.add_child(new_scene.instance())
	Auto.input.set_block_input(false)
	interface.transition.play_backwards("GuiTransitionFade")
