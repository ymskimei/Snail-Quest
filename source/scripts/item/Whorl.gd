extends Node

#signal ended

func _ready():
	if is_instance_valid(SnailQuest.controllable):
		if SnailQuest.controllable is Entity:
			SnailQuest.controllable.set_entity_max_health(3)
#			emit_signal("ended")
