extends Node

var title = preload("res://source/scenes/interface/screen_title.tscn")
var data = preload("res://source/scenes/interface/screen_data.tscn")
var world = preload("res://source/scenes/world/world.tscn")

var game: Node = null
var camera: Spatial = null
var controlled: Spatial = null
var prev_controlled: Spatial = null
var play_time: Node = null
var game_time: Node = null


var info: Dictionary = {
	"title": ProjectSettings.get_setting("application/config/name"),
	"description": ProjectSettings.get_setting("application/config/description"),
	"version": "0.5.0-pre-alpha",
	"author": "Kaboodle"
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

func _ready():
	OS.set_window_title("Snail Quest " + info["version"] + " (DEBUG)")

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
