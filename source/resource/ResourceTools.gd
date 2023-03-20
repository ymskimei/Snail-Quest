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

func add_item(item, added_amount):
	var item_added = false
	for i in range(len(items)):
		if items[i] != null and items[i].item_name == item.item_name and item.stackable:
			items[i].amount += added_amount
			if items[i].amount >= items[i].max_amount and !items[i].max_amount == 0:
				items[i].amount = items[i].max_amount
			elif items[i].amount <= 0:
				if item.depletable:
					remove_item(i)
				else:
					items[i].amount = 0
			item_added = true
			emit_signal("items_updated", [i])
			break
	if item_added == false:
		for i in range(len(items)):
			if items[i] == null:
				set_item(i, item)
				item_added = true
				emit_signal("items_updated", [i])
				break

func switch_item(item_index, target_index):
	var target_item = items[target_index]
	var item = items[item_index]
	items[target_index] = item
	items[item_index] = target_item
	emit_signal("items_updated", [item_index, target_index])
	
func duplicate_item_instances():
	var duplicate_items = []
	for item in items:
		if item is ResourceItem and !item.stackable:
			duplicate_items.append(item.duplicate())
		else:
			duplicate_items.append(null)
		items = duplicate_items
