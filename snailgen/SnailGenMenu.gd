extends Spatial

onready var snail: RigidBody = $Snail
onready var camera: Camera = $Camera
onready var shine: Sprite3D = $Camera/Sprite3D

onready var name_box: LineEdit = $Control/Background/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/LineEdit
onready var color_panel: NinePatchRect = $Control/ColorPicker
onready var color_picker: ColorPicker = $Control/ColorPicker/MarginContainer/Background2/MarginContainer/VBoxContainer/ColorPicker

onready var color_shell: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorShell/TextureColorShell
onready var color_shell_accent: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorShellAccent/TextureColorShellAccent
onready var color_body: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorBody/TextureColorBody
onready var color_body_accent: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorBodyAccent/TextureColorBodyAccent
onready var color_eyes: TextureRect = $Control/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorEyes/TextureColorEyes

var memorized_color: Color = Color("FFFFFF")
var color_to_set: Color = Color("FFFFFF")

var is_color_picking: bool = false

func _ready() -> void:
	name_box.text = snail.name
	_update_display_colors()

func _process(delta: float) -> void:
	if is_color_picking:
		color_to_set = color_picker.color

func _physics_process(delta: float) -> void:
	snail.global_rotation.y += 1 * delta
	shine.global_rotation.z += 0.1 * delta
	camera.global_translation.z = snail.armature.scale.y
	
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
	_open_color_picker(snail.shell_color)

func _on_ButtonColorShellAccent_button_down() -> void:
	_open_color_picker(snail.shell_accent_color)

func _on_ButtonColorBody_button_down() -> void:
	_open_color_picker(snail.body_color)

func _on_ButtonColorBodyAccent_button_down() -> void:
	_open_color_picker(snail.body_accent_color)

func _on_ButtonColorEyes_button_down() -> void:
	_open_color_picker(snail.eye_color)

func _on_ButtonUndo_button_down() -> void:
	color_picker.color = memorized_color

func _on_ButtonBack_button_down() -> void:
	_open_color_picker(memorized_color, false)

func _open_color_picker(to_set: Color, toggle: bool = true) -> void:
	if toggle:
		color_panel.show()
		is_color_picking = true
		color_to_set = to_set
		memorized_color = color_picker.color
	else:
		_update_display_colors()
		is_color_picking = false
		color_panel.hide()

func _update_display_colors() -> void:
	color_shell.modulate = snail.shell_color
	color_shell_accent.modulate = snail.shell_accent_color
	color_body.modulate = snail.body_color
	color_body_accent.modulate = snail.body_accent_color
	color_eyes.modulate = snail.eye_color
