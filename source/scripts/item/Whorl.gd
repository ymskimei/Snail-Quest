extends Node

func _ready():
	if is_instance_valid(Auto.controlled):
		if Auto.controlled is Entity:
			Auto.controlled.set_entity_max_health(3)
