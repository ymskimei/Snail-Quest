extends InventoryParent

func _process(_delta):
	if is_instance_valid(SnailQuest.controllable):
		if Input.is_action_just_pressed("gui_items") and !items_open and !GuiMain.game_paused:
			GuiMain.game_paused = true
			items_open = true
			update_inventory_display()
			$Animation.play("Open")
			$"%Item1".button.grab_focus()
		elif Input.is_action_just_pressed("gui_items") and items_open:
			GuiMain.game_paused = false
			get_tree().set_deferred("paused", false)
			items_open = false
			$Animation.play("Exit")
		if items_open:
			for child in container.get_children():
				if child.is_in_group("item_button") and child.get_node("Button").has_focus():
						var equipment = child.destination
						var item = child.contained_item
						if Input.is_action_just_pressed("pad_up"):
							if item_match(item, equipment.items) != 0:
								Utility.item.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
							Utility.item.set_item(equipment.items, 1, item)
						elif Input.is_action_just_pressed("pad_right"):
							if item_match(item, equipment.items) != 0:
								Utility.item.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
							Utility.item.set_item(equipment.items, 2, item)
						elif Input.is_action_just_pressed("pad_down"):
							if item_match(item, equipment.items) != 0:
								Utility.item.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
							Utility.item.set_item(equipment.items, 3, item)
						elif Input.is_action_just_pressed("pad_left"):
							if item_match(item, equipment.items) != 0:
								Utility.item.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
							Utility.item.set_item(equipment.items, 4, item)

func item_match(i, index: Array) -> int:
	if i == index[1]:
		return 1
	elif i == index[2]:
		return 2
	elif i == index[3]:
		return 3
	elif i == index[4]:
		return 4
	else:
		return 0
