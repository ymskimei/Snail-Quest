extends Node

func _ready():
	if is_instance_valid(SnailQuest.controlled):
		if SnailQuest.controlled is Entity:
			SnailQuest.controlled.set_entity_max_health(3)
