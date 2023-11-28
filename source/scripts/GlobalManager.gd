extends Node

var version_number: String = "0.3.0-pre-alpha"

var worlds: String = "res://source/scenes/world/"
var warps: String = "res://assets/resource/warp/"
var entities: String = "res://source/scenes/entity/"
var objects: String = "res://source/scenes/object/"
var items: String = "res://source/scenes/item/"

var world: Node
var camera: SpringArm
var controllable: PhysicsBody
var prev_controllable: PhysicsBody
var play_time: Node
var game_time: Node

var chunk_start: Vector3 = Vector3.ZERO
var chunk_size: int = 64

func _ready() -> void:
	pass

func set_world(node: Node):
	world = node

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

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			game_focused = true
			emit_signal("game_focus", game_focused)
		NOTIFICATION_WM_FOCUS_OUT:
			game_focused = false
			emit_signal("game_focus", game_focused)
