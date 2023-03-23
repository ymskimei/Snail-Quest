class_name InventoryParent
extends CanvasLayer

onready var container = $"%Container"
export(Resource) var items
var items_open : bool

func _ready():
	items.connect("items_updated", self, "on_items_updated")
	items.duplicate_item_instances()

func update_item_slot_display(item_index):
	var inventory_slot_display = container.get_child(item_index)
	var item = items.items[item_index]
	inventory_slot_display.item_display(item)

func update_inventory_display():
	for item_index in items.items.size():
		update_item_slot_display(item_index)

func on_items_updated(index):
	for item_index in index:
		update_item_slot_display(item_index)
	print(items.items)
