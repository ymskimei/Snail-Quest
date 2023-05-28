extends Node

var version_number = "0.3.0-pre-alpha"

var player : KinematicBody
var aim_cursor : Spatial
var camera : SpringArm
var play_time : Node
var game_time : Node
var chunk_start : Vector3
var chunk_size = 64

func register_camera(node):
	camera = node

func register_player(node):
	player = node

func register_aim_cursor(node):
	aim_cursor = node

func register_play_time(node):
	play_time = node

func register_game_time(node):
	game_time = node

func register_chunk_start(vec):
	chunk_start = vec
