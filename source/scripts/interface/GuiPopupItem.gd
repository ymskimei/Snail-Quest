extends InventoryParent

func _ready() -> void:
	default_focus = $"%Item1"

func _process(delta: float):
	set_hud_items()

func set_inventory(toggle: bool):
	if toggle:
		update_inventory_display()
		show()
		anim.play("Open")
		$"%Item1".button.grab_focus()
	else:
		anim.play("Exit")
		yield(anim, "animation_finished")
		hide()

func set_hud_items() -> void:
	for child in container.get_children():
		if child.is_in_group("item_button") and child.get_node("Button").has_focus():
				var equipment = child.destination
				var item = child.contained_item
				if Input.is_action_just_pressed("pad_up"):
					if item_match(item, equipment.items) != 0:
						Items.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
					Items.set_item(equipment.items, 1, item)
				elif Input.is_action_just_pressed("pad_right"):
					if item_match(item, equipment.items) != 0:
						Items.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
					Items.set_item(equipment.items, 2, item)
				elif Input.is_action_just_pressed("pad_down"):
					if item_match(item, equipment.items) != 0:
						Items.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
					Items.set_item(equipment.items, 3, item)
				elif Input.is_action_just_pressed("pad_left"):
					if item_match(item, equipment.items) != 0:
						Items.replace_item(equipment.items, equipment.items[item_match(item, equipment.items)], null)
					Items.set_item(equipment.items, 4, item)

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
