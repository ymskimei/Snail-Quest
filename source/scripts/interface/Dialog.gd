extends CanvasLayer

export var dialog_skin: Resource
export var dialog_array: Resource

onready var full_bubble: TextureRect = $TextureRect
onready var dialog_bubble: NinePatchRect = $Viewport/MarginContainer/VBoxContainer/DialogBubble
onready var dialog: RichTextLabel = $Viewport/MarginContainer/VBoxContainer/DialogBubble/MarginContainer/Dialog
onready var char_name_bubble: NinePatchRect = $Viewport/MarginContainer/VBoxContainer/MarginContainer/NameBubble
onready var char_name: RichTextLabel = $Viewport/MarginContainer/VBoxContainer/MarginContainer/NameBubble/MarginContainer/Name
onready var indicator: TextureRect =  $Viewport/MarginContainer/TextureRect
onready var indicator_anim: AnimationPlayer = $Viewport/MarginContainer/TextureRect/AnimationPlayer
onready var tween: Tween = $Tween

var full_dialog_array: Array = []

var test_array: Array = [
	"So apparently since you're seeing this text instead of any other text, that means that there's no dialog file actually inserted. So... This is the fallback text.",
	"Either that or you're seeing this from the development side of things, in which case: [speed_1]Here's some varying text speed to try things out. It should be slower than normal.",
	"[speed_3]Okay, back to normal speed again. We'll try faster: [speed_5]This one is the max dialog speed, it goes up on a scale of 0 to 5, default is 3, and instant is 0. That's all."
]

var orig_arr_size: int = 0
var dialog_speed: float = 1
var typing: bool = false
var typing_done: bool = false

func _ready() -> void:
	_set_skin()
	_fade_in()
	yield(tween, "tween_completed")
	indicator_anim.play("Cursor")
	if full_dialog_array:
		full_dialog_array = dialog_array.array
	else:
		full_dialog_array = test_array
	orig_arr_size = full_dialog_array.size()
	set_dialog(full_dialog_array)

func _physics_process(delta: float) -> void:
	if !dialog_skin.instant_dialog:
		_check_dialog_speed()
		if typing:
			dialog.time += dialog_speed * delta / 10
		else:
			dialog.time = 1.0
		if typing_done:
			_typing_ended()
			typing_done = false
	print(dialog.time)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(Device.action_main):
		if dialog.time < 1.0:
			typing = false
			typing_done = true
		else:
			set_dialog(full_dialog_array)

func _typing_ended() -> void:
	_fade_cursor(true)

func _check_dialog_speed() -> void:
	var checkable_chars: int = int(dialog.get_total_character_count() * dialog.time) + 18
	var readable_string: String = dialog.bbcode_text
	if checkable_chars > 0:
		readable_string.erase(checkable_chars, dialog.bbcode_text.length())
	if readable_string.ends_with("[speed_0]"):
		dialog_speed = 10
		dialog.bbcode_text = dialog.bbcode_text.replace("[speed_0]", "")
	elif readable_string.ends_with("[speed_1]"):
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
	var text_with_trans = ""
	if full_dialog_array.size() < orig_arr_size:
		_fade_cursor(false)
	if dialog.custom_effects[transition].resource_name:
		trans = "[" + dialog.custom_effects[transition].resource_name + "]"
	dialog.time = 0
	if full_dialog_array.size() > 0:
		text_with_trans = trans + full_dialog_array.pop_front() + trans
		text_with_trans = text_with_trans.insert(text_with_trans.length() - (trans.length() - 1), "/")
		dialog.bbcode_text = text_with_trans
		typing = true
	else:
		end_dialog()


func set_char_name() -> void:
	char_name.bbcode_text = "AJSKFD"

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
		tween.interpolate_property(indicator, "modulate", Color("#00FFFFFF"), Color("#66CBFF"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		tween.interpolate_property(indicator, "modulate", Color("#66CBFF"), Color("#00FFFFFF"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func end_dialog() -> void:
	_fade_out()
	"END"
