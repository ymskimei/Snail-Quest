extends Node

onready var interface: Node = $Interface

#temp info
var info: Dictionary = {
	"title": "Snail Quest",
	"version": "0.3.0-pre-alpha",
	"author": "© 2023 Studio Kuwagata"
}

var title_screen = preload("res://source/scenes/interface/screen_title.tscn").instance()
var starting_world = preload("res://source/scenes/world/world.tscn").instance()

func _ready():
	SB.set_game(self)
	add_child(title_screen)
	title_screen.connect("game_start", self, "on_start_game")

func on_start_game():
	yield(title_screen, "tree_exited")
	add_child(starting_world)
