extends Sprite3D

@onready var bar: TextureProgressBar = $SubViewport/TextureProgressBar

@export var healthbar: Texture2D

var new_value: float

func _ready() -> void:
	texture = $SubViewport.get_texture()

func _process(_delta: float) -> void:
	bar.value = lerp(bar.value, new_value, 0.2)

func update_bar(body: MeshInstance3D, health: float, max_health: float) -> void:
	var amount = int((health / max_health) * 100)
	new_value = amount
	if body:
		if body == SB.controlled:
			show()
			position.y = body.get_aabb().size.y + 1
		else:
			hide()
