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

func set_game(node: Node) -> void:
	game = node

func get_game() -> Node:
	return game

func set_camera(node: Spatial) -> void:
	camera = node

func get_camera() -> Spatial:
	return camera

func set_controlled(node: Spatial) -> void:
	controlled = node
	if node is Entity:
		node.connect("health_changed", self, "_on_health_changed")

func get_controlled() -> Spatial:
	return controlled

func set_prev_controlled(node: Spatial) -> void:
	prev_controlled = node

func get_prev_controlled() -> Spatial:
	return prev_controlled

func set_world(node: Node) -> void:
	world = node

func get_world() -> Node:
	return world

func set_chunk_start(vec: Vector3) -> void:
	chunk_start = vec

func get_chunk_start() -> Vector3:
	return chunk_start

func set_play_time(node: Node) -> void:
	play_time = node

func get_play_time() -> Node:
	return play_time

func set_game_time(node: Node) -> void:
	game_time = node

func get_game_time() -> Node:
	return game_time

func _on_health_changed(health, max_health, is_controlled) -> void:
	emit_signal("controlled_health_change", health, max_health, is_controlled)
