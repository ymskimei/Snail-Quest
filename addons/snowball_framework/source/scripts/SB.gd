extends Node

onready var utility: Node = $Utility

var game: Node = null
var camera: Spatial = null
var controlled: Spatial = null
var prev_controlled: Spatial = null
var world: Node = null
var play_time: Node = null
var game_time: Node = null

var user_id: String

var cfg: String = "res://addons/snowball_framework/plugin.cfg"

var info: Dictionary = {
	"title": "",
	"description": "",
	"author": "",
	"version": ""
}

var scene: Dictionary = {
	"entity" : "res://source/scenes/entity/",
	"object" : "res://source/scenes/object/",
	"item" : "res://source/scenes/item/",
	"world" : "res://source/scenes/world/"
}

var resource: Dictionary = {
	"warp" : "res://assets/resource/warp/"
}

var chunk_start: Vector3 = Vector3.ZERO
var chunk_size: int = 64

signal controlled_health_change()

func _ready() -> void:
	_set_strings()

func _set_strings() -> void:
	info["title"] = SB.utility.read_config(cfg, "plugin", "name")
	info["description"] = SB.utility.read_config(cfg, "plugin", "description")
	info["author"] = SB.utility.read_config(cfg, "plugin", "author")
	info["version"] = SB.utility.read_config(cfg, "plugin", "version")
	#Move this later
	if OS.has_environment("USERNAME"):
		user_id = OS.get_environment("USERNAME")
	else:
		user_id = ""

func set_game(node: Node):
	game = node

func set_camera(node: Spatial):
	camera = node

func set_controlled(node: Spatial):
	controlled = node
	if node is Entity:
		node.connect("health_changed", self, "_on_health_changed")

func set_prev_controlled(node: Spatial):
	prev_controlled = node

func set_world(node: Node):
	world = node

func set_chunk_start(vec: Vector3):
	chunk_start = vec

func set_play_time(node: Node):
	play_time = node

func set_game_time(node: Node):
	game_time = node

func _on_health_changed(health, max_health, is_controlled):
	emit_signal("controlled_health_change", health, max_health, is_controlled)
