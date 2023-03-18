extends CenterContainer

onready var sprite = $TextureRect
onready var button = $Button

func item_display(item):
	if item is ResourceItem:
		sprite.texture = item.sprite
#	else:
#		self.hide()
