class_name ResourceLootTable
extends Resource

@export var loot_table: Array = [] # (Array, Resource)

func _ready():
	randomize()

func select_item():
	var chosen = null
	if loot_table.size() > 0:
		var chance: int = 0
		for item in loot_table:
			chance += item.loot_chance
		var number = randi() % chance
		var offset: int = 0
		for item in loot_table:
			if number < item.loot_chance + offset:
				chosen = item
				break
			else:
				offset += item.loot_chance
	return chosen
