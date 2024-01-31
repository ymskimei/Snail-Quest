extends RigidBody3D

@export var loot_table: Resource
@export var drop_min = 0
@export var drop_max = 5

var item = preload("res://addons/snowball_framework/source/scenes/item/item.tscn")

func _ready():
	randomize()

func _on_Area_area_entered(area):
	if area.is_in_group("attack"):
		drop_item(randf_range(drop_min, drop_max))
		queue_free()

func drop_item(amount):
	for _i in range(amount):
		var drop = item.instantiate()
		drop.item = loot_table.select_item()
		drop.transform.origin = self.transform.origin
		drop.random_velocity()
		get_parent().add_child(drop)



