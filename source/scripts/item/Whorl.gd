extends Node

#signal ended

func _ready():
	if is_instance_valid(SB.controllable):
		if SB.controllable is Entity:
			SB.controllable.set_entity_max_health(3)
#			emit_signal("ended")
