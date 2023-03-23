extends CenterContainer

export(Resource) var items
export(Resource) var destination

onready var button = $Button
onready var sprite = $Button/ItemSprite
onready var label = $Button/ItemLabel

var contained_item

func item_display(item):
	contained_item = item
	if item is ResourceItem:
		sprite.texture = item.sprite
		if item.stackable:
			label.set_bbcode("[right]" + str(item.amount) + "[/right]")
		else:
			label.set_bbcode("")
	elif !item:
		sprite.texture = null
		label.set_bbcode("")
