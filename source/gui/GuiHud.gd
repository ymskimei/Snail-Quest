extends CanvasLayer

export(Resource) var equipment

onready var tool_slot = $"%ToolSlot"
onready var item_slot_1 = $"%ItemSlot1"
onready var item_slot_2 = $"%ItemSlot2"

func _ready():
	equipment.connect("items_updated", self, "on_items_updated")

func _process(_delta):
	update_inventory_display()

func update_item_slot_display(item_index):
	tool_slot.item_display(equipment.items[0])
	item_slot_1.item_display(equipment.items[1])
	item_slot_2.item_display(equipment.items[2])
	
func update_inventory_display():
	for item_index in equipment.items.size():
		update_item_slot_display(item_index)

func on_items_updated(index):
	for item_index in index:
		update_item_slot_display(item_index)
