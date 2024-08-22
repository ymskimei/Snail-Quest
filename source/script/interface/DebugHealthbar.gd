extends Sprite3D

onready var bar: TextureProgress = $Viewport/TextureProgress

export var healthbar: Texture

var new_value: float

func _ready() -> void:
	texture = $Viewport.get_texture()

func _process(_delta: float) -> void:
	bar.value = lerp(bar.value, new_value, 0.2)

func update_bar(body: MeshInstance, health: float, max_health: float) -> void:
	var amount = int((health / max_health) * 100)
	new_value = amount
	if body:
		translation.y = body.get_aabb().size.y + 1
