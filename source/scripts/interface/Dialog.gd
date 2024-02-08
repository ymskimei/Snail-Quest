extends CanvasLayer

export var dialog_skin: Resource
export var dialog_array: Resource

onready var dialog_bubble: NinePatchRect = $Control/MarginContainer/VBoxContainer/DialogBubble
onready var dialog: RichTextLabel = $Control/MarginContainer/VBoxContainer/DialogBubble/MarginContainer/Dialog
onready var char_name_bubble: NinePatchRect = $Control/MarginContainer/VBoxContainer/NameBubble
onready var char_name: RichTextLabel = $Control/MarginContainer/VBoxContainer/NameBubble/MarginContainer/Name
onready var tween: Tween = $Control/MarginContainer/VBoxContainer/DialogBubble/MarginContainer/Tween

var test_array: Array = [
	"So apparently since you're seeing this text instead of any other text, that means that there's no dialog file actually inserted. So... This is the fallback text.",
	"Either that or you're seeing this from the development side of things, in which case: [speed_1]Here's some varying text speed to try things out. It should be slower than normal.",
	"[speed_3]Okay, back to normal speed again. We'll try faster: [speed_5]This one is the max dialog speed, it goes up on a scale of 0 to 5, default is 3, and instant is 0. That's all."
]

var dialog_speed: float = 1
var typing: bool = false

func _ready() -> void:
	for key in Utility.text_transitions:
		Utility.text_transitions[key].fade_in()
	if dialog_array:
		set_dialog(dialog_array.array)
	else:
		set_dialog(test_array)
	_set_skin()

func _physics_process(delta: float) -> void:
	if !dialog_skin.instant_dialog:
		_check_dialog_speed()
		if typing:
			dialog.time += dialog_speed * delta / 10
		else:
			dialog.time = 1.0

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(Device.action_main):
		if dialog.time < 1.0:
			typing = false
		else:
			set_dialog(test_array)

func _check_dialog_speed() -> void:
	var checkable_chars: int = int(dialog.get_total_character_count() * dialog.time) + 18
	var readable_string: String = dialog.bbcode_text
	if checkable_chars > 0:
		readable_string.erase(checkable_chars, dialog.bbcode_text.length())
	if readable_string.ends_with("[speed_0]"):
		dialog_speed = 10
		dialog.bbcode_text = dialog.bbcode_text.replace("[speed_0]", "")
	elif readable_string.ends_with("[speed_1]"):
		printerr("GOES DING")
		dialog_speed = 0.05
		dialog.bbcode_text = dialog.bbcode_text.replace("[speed_1]", "")
	elif readable_string.ends_with("[speed_2]"):
		dialog_speed = 0.5
		dialog.bbcode_text = dialog.bbcode_text.replace("[speed_2]", "")
	elif readable_string.ends_with("[speed_3]"):
		dialog_speed = 1
		dialog.bbcode_text = dialog.bbcode_text.replace("[speed_3]", "")
	elif readable_string.ends_with("[speed_4]"):
		dialog_speed = 2
		dialog.bbcode_text = dialog.bbcode_text.replace("[speed_4]", "")
	elif readable_string.ends_with("[speed_5]"):
		dialog_speed = 4
		dialog.bbcode_text = dialog.bbcode_text.replace("[speed_5]", "")

func _set_skin() -> void:
	char_name_bubble.texture = dialog_skin.name_texture
	dialog_bubble.texture = dialog_skin.dialog_texture
	char_name_bubble.patch_margin_left = dialog_skin.name_margin_width
	char_name_bubble.patch_margin_right = dialog_skin.name_margin_width
	dialog_bubble.patch_margin_left = dialog_skin.dialog_margin_width
	dialog_bubble.patch_margin_right = dialog_skin.dialog_margin_width
	if !dialog_skin.show_name:
		char_name_bubble.hide()

func set_dialog(arr: Array, transition: int = 0) -> void:
	var trans: String = ""
	if dialog.custom_effects[transition].resource_name:
		trans = "[" + dialog.custom_effects[transition].resource_name + "]"
	dialog.time = 0
	if test_array.size() > 0:
		var text_with_trans = trans + test_array.pop_front() + trans
		text_with_trans = text_with_trans.insert(text_with_trans.length() - (trans.length() - 1), "/")
		dialog.bbcode_text = text_with_trans
		typing = true
	else:
		end_dialog()

func set_char_name() -> void:
	char_name.bbcode_text = "AJSKFD"

func end_dialog() -> void:
	"END"
