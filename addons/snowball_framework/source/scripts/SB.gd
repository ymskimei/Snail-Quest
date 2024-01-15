extends Node

onready var utility: Node = $Utility

var game: Node
var camera: SpringArm
var controllable: Spatial
var prev_controllable: Spatial
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

signal health_changed(health, max_health, b)
signal entity_killed(b)

func set_game(node: Node):
	game = node

func set_camera(node: SpringArm):
	camera = node

func set_controllable(node: Spatial):
	controllable = node

func set_prev_controllable(node: Spatial):
	prev_controllable = node

func set_world(node: Node):
	world = node

func set_chunk_start(vec: Vector3):
	chunk_start = vec

func set_play_time(node: Node):
	play_time = node

func set_game_time(node: Node):
	game_time = node
