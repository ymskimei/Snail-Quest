extends Spatial

onready var snail: RigidBody = $Snail
onready var camera: Camera = $Camera
onready var shine: Sprite3D = $Camera/Sprite3D

onready var name_box: LineEdit = $Control/Background/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/LineEdit
onready var color_panel: NinePatchRect = $Control/ColorPicker
onready var color_picker: ColorPicker = $Control/ColorPicker/MarginContainer/Background2/MarginContainer/VBoxContainer/ColorPicker
onready var size_slider: HSlider = $Control/Background/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/SliderSize

onready var color_display_shell: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorShell/TextureColorShell
onready var color_display_shell_accent: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorShellAccent/TextureColorShellAccent
onready var color_display_body: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorBody/TextureColorBody
onready var color_display_body_accent: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorBodyAccent/TextureColorBodyAccent
onready var color_display_eyes: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorEyes/TextureColorEyes

var memorized_color: Color = Color("FFFFFF")
var color_to_set: int = 0

func _ready() -> void:
	name_box.text = snail.identity.entity_name

func _physics_process(delta: float) -> void:
	snail.global_rotation.y += 1 * delta
	shine.global_rotation.z += 0.1 * delta
	camera.global_translation.z = snail.armature.scale.y
	_update_displays()

func _on_LineEdit_text_changed(new_text: String) -> void:
	snail.set_entity_name(new_text)

func _on_SliderSize_value_changed(value: float) -> void:
	snail.set_entity_scale(value)

func _on_ButtonShellTypeLeft_button_down() -> void:
	snail.set_entity_shell()

func _on_ButtonShellTypeRight_button_down() -> void:
	snail.set_entity_shell(false)

func _on_ButtonShellAccentLeft_button_down() -> void:
	snail.set_entity_swirl()

func _on_ButtonShellAccentRight_button_down() -> void:
	snail.set_entity_swirl(false)

func _on_ButtonBodyTypeLeft_button_down() -> void:
	snail.set_entity_body()

func _on_ButtonBodyTypeRight_button_down() -> void:
	snail.set_entity_body(false)

func _on_ButtonBodyAccentLeft_button_down() -> void:
	snail.set_entity_pattern()

func _on_ButtonBodyAccentRight_button_down() -> void:
	snail.set_entity_pattern(false)

func _on_ButtonEyeLeft_button_down() -> void:
	snail.set_entity_eyes()

func _on_ButtonEyeRight_button_down() -> void:
	snail.set_entity_eyes(false)

func _on_ButtonPupilLeft_button_down() -> void:
	snail.set_entity_pupils()

func _on_ButtonPupilRight_button_down() -> void:
	snail.set_entity_pupils(false)

func _on_ButtonEyelidLeft_button_down() -> void:
	snail.set_entity_eyelids()
 
func _on_ButtonEyelidRight_button_down() -> void:
	snail.set_entity_eyelids(false)

func _on_ButtonColorShell_button_down() -> void:
	_open_color_picker(snail.identity.color_shell_base, 0, true)

func _on_ButtonColorShellAccent_button_down() -> void:
	_open_color_picker(snail.identity.color_shell_accent, 1, true)

func _on_ButtonColorBody_button_down() -> void:
	_open_color_picker(snail.identity.color_body_base, 2, true)

func _on_ButtonColorBodyAccent_button_down() -> void:
	_open_color_picker(snail.identity.color_body_accent, 3, true)

func _on_ButtonColorEyes_button_down() -> void:
	_open_color_picker(snail.identity.color_eyes, 4, true)

func _on_ButtonUndo_button_down() -> void:
	color_picker.color = memorized_color

func _on_ButtonBack_button_down() -> void:
	_open_color_picker(memorized_color)

func _on_ButtonRandom_button_down():
	snail.run_randomizer()
	name_box.text = snail.identity.entity_name
	size_slider.value = snail.identity.entity_scale * 50

func _open_color_picker(to_set: Color, selection: int = 0, toggle: bool = false) -> void:
	if toggle:
		color_panel.show()
		memorized_color = color_picker.color
		color_to_set = selection
		match_to_color()
	else:
		color_panel.hide()

func _update_displays() -> void:
	color_display_shell.modulate = snail.identity.color_shell_base
	color_display_shell_accent.modulate = snail.identity.color_shell_accent
	color_display_body.modulate = snail.identity.color_body_base
	color_display_body_accent.modulate = snail.identity.color_body_accent
	color_display_eyes.modulate = snail.identity.color_eyes

func match_to_color() -> void:
	var c: Color = Color ("FFFFFF")
	match color_to_set:
		0:
			c = snail.identity.color_shell_base
		1:
			c = snail.identity.color_shell_accent
		2:
			c = snail.identity.color_body_base
		3:
			c = snail.identity.color_body_accent
		4:
			c = snail.identity.color_eyes 
	color_picker.color = c

func _on_ColorPicker_color_changed(color) -> void:
	match color_to_set:
		0:
			snail.set_color_shell(color)
		1:
			snail.set_color_shell_accent(color)
		2:
			snail.set_color_body(color)
		3:
			snail.set_color_body_accent(color)
		4:
			snail.set_color_eyes(color)
