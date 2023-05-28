extends Sprite3D

onready var bar = $Viewport/TextureProgress

export var healthbar : Texture

var new_value

func _ready():
	texture = $Viewport.get_texture()

func _process(delta):
	bar.value = lerp(bar.value, new_value, 0.2)

func update_bar(amount, full):
	new_value = amount
