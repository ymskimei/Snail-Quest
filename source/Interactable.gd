class_name Interactable
extends Node

func get_interaction_text():
	return "Interact"

func interaction():
	print("Interacted with %s" % name)
