extends Node

onready var interface: Node = $Interface

var cfg: String = "res://export_presets.cfg"

var info: Dictionary = {
	"title": "",
	"description": "",
	"version": "0.5.0-pre-alpha",
	"author": "Studio Kuwagata"
}

#var dev_stage: String = "pre-alpha"

var title_screen = preload("res://source/scenes/interface/screen_title.tscn").instance()
var world = preload("res://source/scenes/world/world.tscn").instance()

func _ready():
	SB.set_game(self)
	add_child(title_screen)
	title_screen.connect("game_start", self, "on_start_game")
	_set_strings()

func _set_strings() -> void:
	info["title"] = ProjectSettings.get_setting("application/config/name")
	info["description"] = ProjectSettings.get_setting("application/config/description")
	#info["version"] = Utility.read_config(cfg, "preset.0.options", "application/file_version")
	#info["version"].erase(info["version"].length() -2, 2) + "-" + dev_stage
	#info["author"] = Utility.read_config(cfg, "preset.0.options", "application/copyright")

func on_start_game():
	yield(title_screen, "tree_exited")
	add_child(world)
