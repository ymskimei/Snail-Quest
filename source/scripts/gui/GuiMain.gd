extends Node

onready var debug = $GuiDebug

var game_paused : bool

func _process(_delta):
	if game_paused:
		get_tree().set_deferred("paused", true)
