class_name ResourceTools
extends Resource

signal items_updated(index)

export(Array, Resource) var items = [
	null, null, null, null, null, null, null, null, null
]

func set_item(item_index, item):
	var previous_item = items[item_index]
	items[item_index] = item
	emit_signal("items_updated", [item_index])
	return previous_item

func remove_item(item_index):
	var previous_item = items[item_index]
	items[item_index] = null
	emit_signal("items_updated", [item_index])
	return previous_item

func switch_item(item_index, target_index):
	var target_item = items[target_index]
	var item = items[item_index]
	items[target_index] = item
	items[item_index] = target_item
	emit_signal("items_updated", [item_index, target_index])
