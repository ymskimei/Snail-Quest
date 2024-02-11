extends CanvasLayer

export var skin: Resource
export var dialog: Resource

onready var full_bubble: TextureRect = $TextureRect
onready var tween: Tween = $Tween

onready var bubble: NinePatchRect = $Viewport/MarginContainer/VBoxContainer/DialogBubble
onready var text: RichTextLabel = $Viewport/MarginContainer/VBoxContainer/DialogBubble/MarginContainer/Dialog

onready var color: NinePatchRect = $Viewport/MarginContainer/VBoxContainer/MarginContainer/NameBubble
onready var identity: RichTextLabel = $Viewport/MarginContainer/VBoxContainer/MarginContainer/NameBubble/MarginContainer/Name

onready var indicator: TextureRect = $Viewport/MarginContainer/TextureRect
onready var indicator_anim: AnimationPlayer = $Viewport/MarginContainer/TextureRect/AnimationPlayer

var full_dialog_array: Array = []

var orig_arr_size: int = 0
var dialog_speed: float = 1
var typing: bool = false
var typing_done: bool = false

func _ready() -> void:
	_set_skin()
	_fade_in()
	yield(tween, "tween_completed")
	indicator_anim.play("Cursor")
	full_dialog_array = dialog.array
	orig_arr_size = full_dialog_array.size()
	_set_dialog(full_dialog_array)

func _physics_process(delta: float) -> void:
	if !skin.instant_dialog:
		var checkable_chars: int = int(text.get_total_character_count() * text.time) + 18
		var readable_string: String = text.bbcode_text
		if checkable_chars > 0:
			readable_string.erase(checkable_chars, text.bbcode_text.length())
		if readable_string.ends_with("[speed_0]"):
			dialog_speed = 10
			text.bbcode_text = text.bbcode_text.replace("[speed_0]", "")
		elif readable_string.ends_with("[speed_1]"):
			dialog_speed = 0.05
			text.bbcode_text = text.bbcode_text.replace("[speed_1]", "")
		elif readable_string.ends_with("[speed_2]"):
			dialog_speed = 0.5
			text.bbcode_text = text.bbcode_text.replace("[speed_2]", "")
		elif readable_string.ends_with("[speed_3]"):
			dialog_speed = 1
			text.bbcode_text = text.bbcode_text.replace("[speed_3]", "")
		elif readable_string.ends_with("[speed_4]"):
			dialog_speed = 2
			text.bbcode_text = text.bbcode_text.replace("[speed_4]", "")
		elif readable_string.ends_with("[speed_5]"):
			dialog_speed = 4
			text.bbcode_text = text.bbcode_text.replace("[speed_5]", "")
		if typing:
			text.time += dialog_speed * delta / 10
		else:
			text.time = 1.0
		if typing_done:
			_fade_cursor(true)
			typing_done = false

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(Device.action_main):
		if text.time < 1.0:
			typing = false
			typing_done = true
		else:
			_set_dialog(full_dialog_array)

func _set_skin() -> void:
	color.texture = skin.name_texture
	bubble.texture = skin.dialog_texture
	color.patch_margin_left = skin.name_margin_width
	color.patch_margin_right = skin.name_margin_width
	bubble.patch_margin_left = skin.dialog_margin_width
	bubble.patch_margin_right = skin.dialog_margin_width
	if !skin.show_name:
		color.hide()

func _set_dialog(arr: Array, transition: int = 0) -> void:
	var trans: String = ""
	var text_with_trans = ""
	identity.bbcode_text = dialog.name
	if full_dialog_array.size() < orig_arr_size:
		_fade_cursor(false)
	if text.custom_effects[transition].resource_name:
		trans = "[" + text.custom_effects[transition].resource_name + "]"
	text.time = 0
	if full_dialog_array.size() > 0:
		text_with_trans = trans + full_dialog_array.pop_front() + trans
		text_with_trans = text_with_trans.insert(text_with_trans.length() - (trans.length() - 1), "/")
		text.bbcode_text = text_with_trans
		typing = true
	else:
		_fade_out()
		"END"

func _fade_in() -> void:
	tween.interpolate_property(full_bubble, "rect_position:y", 512, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(full_bubble.material, "shader_param/x_rot", -20, 0, 1, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.interpolate_property(full_bubble, "modulate", Color("#00FFFFFF"), Color("#FFFFFF"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _fade_out() -> void:
	tween.interpolate_property(full_bubble, "rect_position:y", 0, 512, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(full_bubble.material, "shader_param/x_rot", 0, -20, 1, Tween.TRANS_ELASTIC, Tween.EASE_IN)
	tween.interpolate_property(full_bubble, "modulate", Color("#FFFFFF"), Color("#00FFFFFF"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.start()

func _fade_cursor(fade_in: bool = true) -> void:
	if fade_in:
		tween.interpolate_property(indicator, "self_modulate", Color("#00FFFFFF"), Color("#66CBFF"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		tween.interpolate_property(indicator, "self_modulate", Color("#66CBFF"), Color("#00FFFFFF"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
