extends Node

var title = preload("res://source/scene/interface/screen_title.tscn")
var data = preload("res://source/scene/interface/screen_data.tscn")
var world = preload("res://source/scene/world/world.tscn")

var game: Node = null
var camera: Spatial = null
var controlled: PhysicsBody = null
var prev_controlled: PhysicsBody = null
var play_time: Node = null
var game_time: Node = null

var info: Dictionary = {
	"title": ProjectSettings.get_setting("application/config/name"),
	"description": ProjectSettings.get_setting("application/config/description"),
	"version": "0.5.0-pre-alpha",
	"author": "Kaboodle"
}

var scene: Dictionary = {
	"entity" : "res://source/scene/entity/",
	"object" : "res://source/scene/object/",
	"item" : "res://source/scene/item/",
	"world" : "res://source/scene/world/"
}

var resource: Dictionary = {
	"warp" : "res://assets/resource/warp/"
}

var chunk_start: Vector3 = Vector3.ZERO
var chunk_size: int = 64

#signal game_time_active()
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

func set_controlled(node: PhysicsBody) -> void:
	if controlled:
		prev_controlled = controlled
		if "listener" in prev_controlled:
			prev_controlled.listener.clear_current()

	controlled = node

	if "listener" in node:
		node.listener.make_current()

	if node is Entity:
		node.connect("health_changed", self, "_on_health_changed")

func get_controlled() -> PhysicsBody:
	return controlled

func set_prev_controlled(node: PhysicsBody) -> void:
	prev_controlled = node

func get_prev_controlled() -> PhysicsBody:
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
#	emit_signal("game_time_active")

func get_game_time() -> Node:
	return game_time

func _on_health_changed(health, max_health, is_controlled) -> void:
	emit_signal("controlled_health_change", health, max_health, is_controlled)
