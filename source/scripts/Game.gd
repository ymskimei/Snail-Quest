extends Node

onready var interface: Node = $Interface

var title_screen = preload("res://source/scenes/interface/screen_title.tscn").instance()
var world = preload("res://source/scenes/world/world.tscn").instance()

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
	add_child(title_screen)
	title_screen.connect("game_start", self, "on_start_game")

func on_start_game():
	yield(title_screen, "tree_exited")
	add_child(world)
