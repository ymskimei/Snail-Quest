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
						if Input.is_action_just_pressed("action_item_0"):
							if item == equipment.items[2]:
								Utility.item.replace_item(equipment.items, equipment.items[2], null)
							Utility.item.set_item(equipment.items, 1, item)
						elif Input.is_action_just_pressed("action_item_1"):
							if item == child.destination.items[1]:
								Utility.item.replace_item(equipment.items, equipment.items[1], null)
							Utility.item.set_item(equipment.items, 2, item)
