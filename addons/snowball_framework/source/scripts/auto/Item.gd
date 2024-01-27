extends Node

signal items_updated(index)

func set_item(items: Array, item_index: int, item) -> int:
	var previous_item = items[item_index]
	items[item_index] = item
	emit_signal("items_updated", [item])
	return previous_item

func remove_item(items: Array, item_index: int) -> int:
	var previous_item = items[item_index]
	items[item_index] = null
	emit_signal("items_updated", [item_index])
	return previous_item

func add_item(items: Array, item, added_amount: int) -> void:
	var item_added = false
	for i in range(len(items)):
		if items[i] != null and items[i].item_name == item.item_name and item.stackable:
			items[i].amount += added_amount
			if items[i].amount >= items[i].max_amount and !items[i].max_amount == 0:
				items[i].amount = items[i].max_amount
			elif items[i].amount <= 0:
				if item.depletable:
					remove_item(items, i)
				else:
					items[i].amount = 0
			item_added = true
			emit_signal("items_updated", [i])
			break
	if item_added == false:
		for i in range(len(items)):
			if items[i] == null:
				set_item(items, i, item)
				item_added = true
				emit_signal("items_updated", [i])
				break

func switch_item(items: Array, item_index: int, target_index: int) -> void:
	var target_item = items[target_index]
	var item = items[item_index]
	items[target_index] = item
	items[item_index] = target_item
	emit_signal("items_updated", [item_index, target_index])

func replace_item(target_index: Array, item: int, new_item: int) -> void:
	var i = target_index.find(item)
	if(i != -1):
		target_index[i] = new_item
	emit_signal("items_updated", [new_item])

func duplicate_item_instances(items: Array) -> void:
	var duplicate_items = []
	for item in items:
		if item is ResourceItem and !item.stackable:
			duplicate_items.append(item.duplicate())
		else:
			duplicate_items.append(null)
		items = duplicate_items
