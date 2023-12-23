extends Node

onready var interface: Node = $Interface
onready var audio: Node = $Audio

var version_number: String = "0.3.0-pre-alpha"

var world: Node
var camera: SpringArm
var controllable: Spatial
var prev_controllable: Spatial
var play_time: Node
var game_time: Node

var worlds: String = "res://source/scenes/world/"
var warps: String = "res://assets/resource/warp/"
var entities: String = "res://source/scenes/entity/"
var objects: String = "res://source/scenes/object/"
var items: String = "res://source/scenes/item/"

var starting_world = preload("res://source/scenes/world/world.tscn").instance()

var chunk_start: Vector3 = Vector3.ZERO
var chunk_size: int = 64

signal health_changed(health, max_health, b)
signal entity_killed(b)

#EventFlags
var izabell_has_met: bool = false

func set_world(node: Node):
	world = node

func set_camera(node: SpringArm):
	camera = node

func set_controllable(node: Spatial):
	controllable = node

func set_prev_controllable(node: Spatial):
	prev_controllable = node

func set_play_time(node: Node):
	play_time = node

func set_game_time(node: Node):
	game_time = node

func set_chunk_start(vec: Vector3):
	chunk_start = vec

#func _unhandled_input(event):
#	if Input.get_connected_joypads().size() >= 0:
#		print("controller")
#	else:
#		print("keyboard")
