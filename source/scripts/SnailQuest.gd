class_name SnailQuest
extends Node

var world = preload("res://source/scenes/world/world.tscn").instance()
var title_screen = preload("res://source/scenes/gui/gui_screen_title.tscn").instance()

func _ready():
	add_child(title_screen)
	title_screen.connect("game_start", self, "on_Game_Started")

func on_Game_Started():
	print("demo")
	yield(title_screen, "tree_exited")
	add_child(world)

#func _unhandled_input(event):
#	if Input.get_connected_joypads().size() >= 0:
#		print("controller")
#	else:
#		print("keyboard")
