extends Node

onready var debug = $GuiDebug

export var version_number = "0.3.0-pre-alpha"
var game_paused : bool
var player_exists : bool

#func _ready():
#	connect("player_exists", self, "on_player_exists")

func _process(delta):
	if game_paused:
		get_tree().set_deferred("paused", true)
