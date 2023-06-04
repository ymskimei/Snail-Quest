class_name ObjectInteractable
extends Node

func get_interaction_text():
	return "Interact"

func interaction():
	print("Interacted with %s" % name)
