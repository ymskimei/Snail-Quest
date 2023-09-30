extends Node

var version_number = "0.3.0-pre-alpha"

var camera : SpringArm
var aim_cursor : Spatial
var player : Entity
var vehicle : PhysicsBody
var play_time : Node
var game_time : Node
var chunk_start : Vector3
var chunk_size = 64

func register_camera(node : SpringArm):
	camera = node

func register_aim_cursor(node : Spatial):
	aim_cursor = node

func register_player(node : Entity):
	player = node

func register_vehicle(node : PhysicsBody):
	vehicle = node

func deregister_vehicle():
	vehicle = null

func register_play_time(node : Node):
	play_time = node

func register_game_time(node : Node):
	game_time = node

func register_chunk_start(vec : Vector3):
	chunk_start = vec
