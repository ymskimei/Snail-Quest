extends MarginContainer

export(Resource) var tools

onready var tool_display_left = $"%ToolDisplayLeft"
onready var tool_display_down = $"%ToolDisplayBottom"
onready var tool_display_right = $"%ToolDisplayRight"
onready var tool_display_up = $"%ToolDisplayTop"

func _ready():
	tools.connect("items_updated", self, "on_items_updated")

func _process(_delta):
	update_inventory_display()

func _unhandled_input(event):
	if Input.is_action_just_pressed("pad_left"):
		tool_display_left.selection_animation()

func update_item_slot_display(item_index):
	tool_display_right.item_display(tools.items[0])
	tool_display_down.item_display(tools.items[1])
	tool_display_left.item_display(tools.items[2])
	tool_display_up.item_display(tools.items[3])
	
func update_inventory_display():
	for item_index in tools.items.size():
		update_item_slot_display(item_index)

func on_items_updated(index):
	for item_index in index:
		update_item_slot_display(item_index)
