extends Sprite3D

onready var bar: TextureProgress = $Viewport/TextureProgress

export var healthbar: Texture

var new_value: float

func _ready() -> void:
	texture = $Viewport.get_texture()

func _process(_delta: float) -> void:
	bar.value = lerp(bar.value, new_value, 0.2)

func update_bar(amount: float) -> void:
	new_value = amount
