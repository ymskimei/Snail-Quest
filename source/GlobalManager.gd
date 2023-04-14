extends Node

var version_number = "0.3.0-pre-alpha"

var player : KinematicBody
var camera : SpringArm
var play_time : Node
var game_time : Node
var chunk_coords : Vector3

func register_camera(node):
	camera = node

func register_player(node):
	player = node

func register_play_time(node):
	play_time = node

func register_game_time(node):
	game_time = node

func register_chunk_coords(vec):
	chunk_coords = vec
