extends Node

func _ready():
	if is_instance_valid(SB.controlled):
		if SB.controlled is Entity:
			SB.controlled.set_entity_max_health(3)
