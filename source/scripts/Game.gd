extends Node

onready var interface: Node = $Interface
onready var dialog_randomizer: Node = $Resource/DialogRandomizer

var cfg: String = "res://export_presets.cfg"

var info: Dictionary = {
	"title": "",
	"description": "",
	"version": "0.5.0-pre-alpha",
	"author": "Studio Kuwagata"
}

#var dev_stage: String = "pre-alpha"

export var title_screen: PackedScene
export var world: PackedScene
export var cache: PackedScene

var first_scene = null

func _ready():
	randomize()
	SB.set_game(self)
	first_scene = title_screen.instance()
	add_child(first_scene)
	first_scene.connect("game_start", self, "on_start_game")
	_set_strings()
	add_child(cache.instance())

func _set_strings() -> void:
	info["title"] = ProjectSettings.get_setting("application/config/name")
	info["description"] = ProjectSettings.get_setting("application/config/description")
	#info["version"] = Utility.read_config(cfg, "preset.0.options", "application/file_version")
	#info["version"].erase(info["version"].length() -2, 2) + "-" + dev_stage
	#info["author"] = Utility.read_config(cfg, "preset.0.options", "application/copyright")

func on_start_game():
	yield(first_scene, "tree_exited")
	add_child(world.instance())
