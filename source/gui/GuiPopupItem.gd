extends InventoryParent

func _process(delta):
	if Input.is_action_just_pressed("gui_items") and items_open == false:
		update_inventory_display()
		$Animation.play("Open")
		get_tree().set_deferred("paused", true)
		items_open = true
		$"%Item1".button.grab_focus()
	elif Input.is_action_just_pressed("gui_items") and items_open == true:
		$Animation.play("Exit")
		get_tree().set_deferred("paused", false)
		items_open = false
	if items_open:
		for child in container.get_children():
			if child.is_in_group("item_button") and child.get_node("Button").has_focus():
					var equipment = child.destination
					var item = child.contained_item
					if Input.is_action_just_pressed("action_item_0"):
						if item == equipment.items[2]:
							equipment.replace_item(equipment.items, equipment.items[2], null)
						equipment.set_item(1, item)
					elif Input.is_action_just_pressed("action_item_1"):
						if item == child.destination.items[1]:
							equipment.replace_item(equipment.items, equipment.items[1], null)
						equipment.set_item(2, item)
