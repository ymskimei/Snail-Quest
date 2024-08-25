class_name ResourceIdentity
extends Resource

export var entity_name: String = "???"
export var entity_personality: int = 0
export var entity_scale: float = 1.0

export var mesh_shell: Mesh = null
export var mesh_body: Mesh = null
export var mesh_eye_left: Mesh = null
export var mesh_eye_right: Mesh = null

export var pattern_shell: Texture = null
export var pattern_body: Texture = null
export var pattern_eyes: Texture = null
export var pattern_eyelids: Texture = null

export var color_shell_base: Color = Color("FFFFFF")
export var color_shell_accent: Color = Color("00ffffff")

export var color_body_base: Color = Color("FFFFFF")
export var color_body_accent: Color = Color("00ffffff")

export var color_eyes: Color = Color("FFFFFF")

export var mesh_hat: Mesh = null
export var pattern_hat: Texture = null
export var pattern_sticker: Texture = null

func set_entity_name(name: String) -> void:
	entity_name = name

func get_entity_name() -> String:
	return entity_name

func set_entity_personality(type: int) -> void:
	entity_personality = type

func get_entity_personality() -> int:
	return entity_personality

func set_entity_scale(size: float) -> void:
	entity_scale = size

func get_entity_scale() -> float:
	return entity_scale

func set_mesh_shell(mesh: Mesh) -> void:
	mesh_shell = mesh

func get_mesh_shell() -> Mesh:
	return mesh_shell

func set_mesh_body(mesh: Mesh) -> void:
	mesh_body = mesh

func get_mesh_body() -> Mesh:
	return mesh_body

func set_mesh_eye_left(mesh: Mesh) -> void:
	mesh_eye_left = mesh

func get_mesh_eye_left() -> Mesh:
	return mesh_eye_left

func set_mesh_eye_right(mesh: Mesh) -> void:
	mesh_eye_right = mesh

func get_mesh_eye_right() -> Mesh:
	return mesh_eye_right

func set_pattern_shell(sprite: Texture) -> void:
	pattern_shell = sprite

func get_pattern_shell() -> Texture:
	return pattern_shell

func set_pattern_body(sprite: Texture) -> void:
	pattern_body = sprite

func get_pattern_body() -> Texture:
	return pattern_body
	
func set_pattern_eyes(sprite: Texture) -> void:
	pattern_eyes = sprite

func get_pattern_eyes() -> Texture:
	return pattern_eyes

func set_pattern_eyelids(sprite: Texture) -> void:
	pattern_eyelids = sprite

func get_pattern_eyelids() -> Texture:
	return pattern_eyelids

func set_color_shell_base(shade: Color) -> void:
	color_shell_base = shade

func get_color_shell_base() -> Color:
	return color_shell_base

func set_color_shell_accent(shade: Color) -> void:
	color_shell_accent = shade

func get_color_shell_accent() -> Color:
	return color_shell_accent

func set_color_body_base(shade: Color) -> void:
	color_body_base = shade

func get_color_body_base() -> Color:
	return color_body_base

func set_color_body_accent(accent: Color) -> void:
	color_body_accent = accent

func get_color_body_accent() -> Color:
	return color_body_accent

func set_color_eyes(shade: Color) -> void:
	color_eyes = shade

func get_color_eyes() -> Color:
	return color_eyes
	
func set_mesh_hat(mesh: Mesh) -> void:
	mesh_hat = mesh

func get_mesh_hat() -> Mesh:
	return mesh_hat

func set_pattern_hat(sprite: Texture) -> void:
	pattern_hat = sprite

func get_pattern_hat() -> Texture:
	return pattern_hat

func set_pattern_sticker(sprite: Texture) -> void:
	pattern_sticker = sprite

func get_pattern_sticker() -> Texture:
	return pattern_sticker
