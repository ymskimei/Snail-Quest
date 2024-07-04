extends Spatial

onready var snail: RigidBody = $Snail
onready var camera: Camera = $Camera
onready var shine: Sprite3D = $Camera/Sprite3D

onready var play: Button = $Control/HBoxContainer/MarginContainer/HBoxContainer/ButtonPlay
onready var rewind: Button = $Control/HBoxContainer/MarginContainer/HBoxContainer/ButtonLeft
onready var forward: Button = $Control/HBoxContainer/MarginContainer/HBoxContainer/ButtonRight

onready var name_box: LineEdit = $Control/HBoxContainer/Background/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/LineEdit
onready var size_slider: HSlider = $Control/HBoxContainer/Background/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/SliderSize
onready var color_panel: NinePatchRect = $Control/ColorPicker
onready var color_picker: ColorPicker = $Control/ColorPicker/MarginContainer/Background2/MarginContainer/VBoxContainer/ColorPicker
onready var resource_loader: NinePatchRect = $Control/ResourceLoader
onready var file_container: VBoxContainer = $Control/ResourceLoader/MarginContainer/Background2/MarginContainer/VBoxContainer/ScrollContainer/FileContainer

onready var color_display_shell: TextureRect = $Control/HBoxContainer/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorShell/TextureColorShell
onready var color_display_shell_accent: TextureRect = $Control/HBoxContainer/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorShellAccent/TextureColorShellAccent
onready var color_display_body: TextureRect = $Control/HBoxContainer/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorBody/TextureColorBody
onready var color_display_body_accent: TextureRect = $Control/HBoxContainer/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorBodyAccent/TextureColorBodyAccent
onready var color_display_eyes: TextureRect = $Control/HBoxContainer/Background/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/ButtonColorEyes/TextureColorEyes

var button_play: Texture = load("res://snailgen/play.png")
var button_pause: Texture = load("res://snailgen/pause.png")

var resource_path: String = "res://assets/resource/identity/snail/"

var memorized_color: Color = Color("FFFFFF")
var color_to_set: int = 0

var spinning: bool = true

func _ready() -> void:
	_update_from_identity()

func _physics_process(delta: float) -> void:
	if spinning:
		snail.global_rotation.y += 1 * delta
	else:
		if rewind.pressed:
			snail.global_rotation.y += 3 * delta
		elif forward.pressed:
			snail.global_rotation.y -= 3 * delta
	shine.global_rotation.z += 0.1 * delta
	camera.global_translation.z = snail.armature.scale.y
	_update_displays()

func _on_ButtonPlay_toggled(button_pressed):
	if button_pressed:
		spinning = false
		play.icon = button_play
	else:
		spinning = true
		play.icon = button_pause

func _on_ButtonLeft_button_down():
	if spinning:
		spinning = false
		play.icon = button_play

func _on_ButtonRight_button_down():
	if spinning:
		spinning = false
		play.icon = button_play

func _on_LineEdit_text_changed(new_text: String) -> void:
	snail.set_entity_name(new_text)

func _on_SliderSize_value_changed(value: float) -> void:
	snail.set_entity_scale(value)

func _on_ButtonShellTypeLeft_button_down() -> void:
	snail.set_entity_shell()
	_play_sound_select()

func _on_ButtonShellTypeRight_button_down() -> void:
	snail.set_entity_shell(false)
	_play_sound_select()

func _on_ButtonShellAccentLeft_button_down() -> void:
	snail.set_entity_swirl()
	_play_sound_select()

func _on_ButtonShellAccentRight_button_down() -> void:
	snail.set_entity_swirl(false)
	_play_sound_select()

func _on_ButtonBodyTypeLeft_button_down() -> void:
	snail.set_entity_body()
	_play_sound_select()

func _on_ButtonBodyTypeRight_button_down() -> void:
	snail.set_entity_body(false)
	_play_sound_select()

func _on_ButtonBodyAccentLeft_button_down() -> void:
	snail.set_entity_pattern()
	_play_sound_select()

func _on_ButtonBodyAccentRight_button_down() -> void:
	snail.set_entity_pattern(false)
	_play_sound_select()

func _on_ButtonEyeLeft_button_down() -> void:
	snail.set_entity_eyes()
	_play_sound_select()

func _on_ButtonEyeRight_button_down() -> void:
	snail.set_entity_eyes(false)
	_play_sound_select()

func _on_ButtonHatLeft_button_down():
	snail.set_entity_hat()
	_play_sound_select()

func _on_ButtonHatRight_button_down():
	snail.set_entity_hat(false)
	_play_sound_select()

func _on_ButtonColorShell_button_down() -> void:
	_open_color_picker(snail.identity.color_shell_base, 0, true)
	_play_sound_select()

func _on_ButtonColorShellAccent_button_down() -> void:
	_open_color_picker(snail.identity.color_shell_accent, 1, true)
	_play_sound_select()

func _on_ButtonColorBody_button_down() -> void:
	_open_color_picker(snail.identity.color_body_base, 2, true)
	_play_sound_select()

func _on_ButtonColorBodyAccent_button_down() -> void:
	_open_color_picker(snail.identity.color_body_accent, 3, true)
	_play_sound_select()

func _on_ButtonColorEyes_button_down() -> void:
	_open_color_picker(snail.identity.color_eyes, 4, true)
	_play_sound_select()

func _on_ButtonPupilLeft_button_down() -> void:
	snail.set_entity_pupils()
	_play_sound_select()

func _on_ButtonPupilRight_button_down() -> void:
	snail.set_entity_pupils(false)
	_play_sound_select()

func _on_ButtonEyelidLeft_button_down() -> void:
	snail.set_entity_eyelids()
	_play_sound_select()

func _on_ButtonEyelidRight_button_down() -> void:
	snail.set_entity_eyelids(false)
	_play_sound_select()

func _on_ButtonStickerLeft_button_down():
	snail.set_entity_sticker()
	_play_sound_select()

func _on_ButtonStickerRight_button_down():
	snail.set_entity_sticker(false)
	_play_sound_select()

func _on_ButtonUndo_button_down() -> void:
	color_picker.color = memorized_color
	_play_sound_exit()

func _on_ButtonBack_button_down() -> void:
	_open_color_picker(memorized_color)
	_play_sound_exit()

func _on_ButtonRandom_button_down() -> void:
	snail.run_randomizer()
	_update_from_identity()
	_play_sound_select()

func _on_ButtonSave_button_down() -> void:
	snail.save_resource(resource_path + "generated/")
	_play_sound_success()

func _on_ButtonLoad_button_down() -> void:
	open_file_container(resource_path, true)
	_play_sound_select()

func _on_ButtonLoadBack_button_down() -> void:
	open_file_container(resource_path)
	_play_sound_exit()
	
func open_file_container(path: String, toggle: bool = false) -> void:
	if toggle:
		populate_file_container(resource_path)
		resource_loader.show()
	else:
		resource_loader.hide()
		populate_file_container(resource_path, false)
		_update_from_identity()

func populate_file_container(path: String, toggle: bool = true) -> void:
	var resources = Auto.utility.get_files(path, true, true)
	if toggle:
		for i in resources:
			var button = Button.new()
			var file_name = i.get_file()
			file_name.erase(file_name.length() - 5, 5)
			button.text = file_name.capitalize()
			file_container.add_child(button)
			button.connect("pressed", self, "_on_File_selected", [i])
	else:
		for m in file_container.get_children():
			m.queue_free()

func _on_File_selected(path) -> void:
	snail.load_resource(path)
	open_file_container(resource_path)

func _open_color_picker(to_set: Color, selection: int = 0, toggle: bool = false) -> void:
	if toggle:
		color_panel.show()
		memorized_color = color_picker.color
		color_to_set = selection
		match_to_color()
	else:
		color_panel.hide()

func _update_from_identity() -> void:
	name_box.text = snail.identity.entity_name
	size_slider.value = snail.identity.entity_scale * 50

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

func _play_sound_select() -> void:
	Utility.audio.play_sfx(RegistryAudio.tone_switch)

func _play_sound_success() -> void:
	Utility.audio.play_sfx(RegistryAudio.tone_success)
	
func _play_sound_exit() -> void:
	Utility.audio.play_sfx(RegistryAudio.tone_exit)



