extends Node

var version_number = "0.3.0-pre-alpha"

var game_focused: bool = true

var screen : Node
var player : KinematicBody
var camera : SpringArm
var aim_cursor : Spatial
var play_time : Node
var game_time : Node

var chunk_start : Vector3
var chunk_size = 64

var control_invert_vertical: bool = false
var control_invert_horizontal: bool = false

signal game_focus(is_focused)

func register_screen(node):
	screen = node

func register_player(node):
	player = node

func register_camera(node):
	camera = node

func register_aim_cursor(node):
	aim_cursor = node

func register_play_time(node):
	play_time = node

func register_game_time(node):
	game_time = node

func register_chunk_start(vec):
	chunk_start = vec

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			game_focused = true
			emit_signal("game_focus", game_focused)
		NOTIFICATION_WM_FOCUS_OUT:
			game_focused = false
			emit_signal("game_focus", game_focused)
