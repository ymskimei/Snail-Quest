extends Node

var version_number: String = "0.3.0-pre-alpha"

var camera: SpringArm
var controllable: PhysicsBody
var prev_controllable: PhysicsBody
var play_time: Node
var game_time: Node

var chunk_start: Vector3 = Vector3.ZERO
var chunk_size: int = 64

func _ready() -> void:
	pass

func set_camera(node: SpringArm):
	camera = node

func set_controllable(node: Entity):
	controllable = node

func set_play_time(node: Node):
	play_time = node

func set_game_time(node: Node):
	game_time = node

func set_chunk_start(vec: Vector3):
	chunk_start = vec
