extends RigidBody

export(Resource) var loot_table
export var drop_min = 0
export var drop_max = 5

var item = preload("res://assets/object/item_parent.tscn")

func _ready():
	randomize()

func _on_Area_body_entered(body):
	if body is Player:
		drop_item(rand_range(drop_min, drop_max))
		queue_free()

func drop_item(amount):
	for _i in range(amount):
		var drop = item.instance()
		drop.item = loot_table.select_item()
		drop.transform.origin = self.transform.origin
		drop.random_velocity()
		get_parent().add_child(drop)
