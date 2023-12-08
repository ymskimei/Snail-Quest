extends Node

func _ready():
	add_child(SnailQuest.title_screen)
	SnailQuest.title_screen.connect("game_start", self, "on_Game_Started")

func on_Game_Started():
	yield(SnailQuest.title_screen, "tree_exited")
	add_child(SnailQuest.starting_world)
