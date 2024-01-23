extends Node

onready var utility: Node = $Utility

var game: Node
var camera: Spatial
var controlled: Spatial
var prev_controlled: Spatial
var world: Node
var play_time: Node
var game_time: Node

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
