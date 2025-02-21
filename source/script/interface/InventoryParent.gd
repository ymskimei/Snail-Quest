class_name InventoryParent
extends Menu

onready var container = $"%Container"
export(Resource) var items

func _ready() -> void:
	#yield(Auto, "ready")
	if is_instance_valid(Items):
		Items.connect("items_updated", self, "on_items_updated")
		Items.duplicate_item_instances(items.items)

func update_item_slot_display(item_index: int) -> void:
	var inventory_slot_display = container.get_child(item_index)
	var item = items.items[item_index]
	inventory_slot_display.item_display(item)

func update_inventory_display() -> void:
	for item_index in items.items.size():
		update_item_slot_display(item_index)

func on_items_updated(index: Array) -> void:
	for item_index in index.size():
		update_item_slot_display(item_index)
