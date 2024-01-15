extends CenterContainer

export(Resource) var destination

onready var sprite = $ItemSprite
onready var label = $ItemLabel

onready var anim = $AnimationPlayer

var contained_item
var selected : bool

func _ready():
	anim.connect("animation_finished", self, "is_selected_animation")

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

func is_selected_animation():
		anim.play("GuiItemBounce")

func still_selected_animation():
	anim.play("GuiItemStill")

func is_deselected_animation():
	anim.play("GuiItemDisabled")
