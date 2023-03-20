extends CenterContainer

var tools = preload("res://resource/tools.tres")
onready var button = $Button
onready var label = $Button/ItemLabel

func item_display(item):
	if item is ResourceItem:
		button.texture_normal = item.sprite
		if item.stackable:
			label.text = str(item.amount)
