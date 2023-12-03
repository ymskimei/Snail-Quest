class_name SnailQuest
extends Node

onready var screen_canvas = $ColorFilter

var world = preload("res://source/scenes/world/world.tscn").instance()
var title_screen = preload("res://source/scenes/gui/gui_screen_title.tscn").instance()

func _ready():
	screen_canvas.add_child(title_screen)
	title_screen.connect("game_start", self, "on_Game_Started")

func on_Game_Started():
	print("demo")
	yield(title_screen, "tree_exited")
	screen_canvas.add_child(world)
