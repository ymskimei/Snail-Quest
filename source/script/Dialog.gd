extends CanvasLayer

export var bbcode_transition_label: PackedScene

onready var dialog_bubble: MarginContainer = $DialogContainer
onready var container: HFlowContainer = $DialogContainer/NinePatchRect/MarginContainer/HFlowContainer
onready var shadows_container: HFlowContainer = $DialogContainer/NinePatchRect/MarginContainer/MarginContainer/HFlowContainerShadows
onready var dialog_name: Label = $DialogContainer/NameContainer/TextureRect/Label

onready var branch_bubble: MarginContainer = $DialogContainer/BranchContainer
onready var branch_button_0: Button = $DialogContainer/BranchContainer/NinePatchRect/VBoxContainer/Button
onready var branch_button_1: Button = $DialogContainer/BranchContainer/NinePatchRect/VBoxContainer/Button2
onready var branch_button_2: Button = $DialogContainer/BranchContainer/NinePatchRect/VBoxContainer/Button3
onready var branch_button_3: Button = $DialogContainer/BranchContainer/NinePatchRect/VBoxContainer/Button4

onready var question_bubble: MarginContainer = $QuestionContainer
onready var question_text: RichTextLabel = $QuestionContainer/VBoxContainer/RichTextTransition
onready var line_edit: LineEdit = $QuestionContainer/VBoxContainer/LineEdit

var word_timer: Timer

var dialog_character_limit: int = 256
var break_chars: Array = ["!", ".", "?", "..."]

var current_dialog_keys: Array = ["TEST_PHRASE_1", "TEST_PHRASE_2", "TEST_PHRASE_3"]
var current_dialog_key: String = ""

var dialog_display_name: String = ""
var dialog_color: Color = Color.cornflower
var dialog_in_pages: Array = []
var current_dialog_words: Array = []

var current_word: int = 0
var page_type_in_wait: int = 0
var current_font: String = "res://assets/interface/font/nishiki_teki_40.tres"
var current_color: Array = ["", ""]
var current_bbcode: Array = ["", ""]
var function_to_update: String = ""

var dialog_speed: float = 2
var dialog_speed_modifier: float = 1

var input_allowed: bool = true

signal dialog_ended()

func _ready() -> void:
	if dialog_display_name != "":
		var texture_id: String = dialog_display_name
		texture_id.erase(0, 7)
		dialog_bubble.get_child(0).set_texture(load("res://assets/texture/interface/menu/dialog/dialog_%s.png" % texture_id.to_lower()))
		dialog_name.set_text(tr(dialog_display_name))

		var dialog_bubble_image: Image = dialog_bubble.get_child(0).get_texture().get_data()
		dialog_bubble_image.lock()
		dialog_name.get_parent().set_self_modulate(dialog_bubble_image.get_pixel(0, dialog_bubble_image.get_height() / 2))
		if dialog_bubble_image.get_pixel(dialog_bubble_image.get_width() / 2, dialog_bubble_image.get_height() / 2).get_luminance() <= 0.5:
			current_color = ["[color=white]", "[/color]"]
	else:
		dialog_bubble.get_child(0).set_texture(load("res://assets/texture/interface/menu/dialog/dialog_sign.png"))
		current_color = ["[color=black]", "[/color]"]
		dialog_name.get_parent().set_visible(false)

	question_bubble.set_visible(false)
	branch_button_0.set_visible(false)
	branch_button_1.set_visible(false)
	branch_button_2.set_visible(false)
	branch_button_3.set_visible(false)
	branch_bubble.set_visible(false)

	word_timer = Timer.new()
	word_timer.set_one_shot(true)
	word_timer.set_wait_time(0.1)
	word_timer.connect("timeout", self, "_on_word_timeout")
	add_child(word_timer)

	current_dialog_key = current_dialog_keys.pop_front()
	_load_new_dialog(current_dialog_key)
	_new_dialog_page(dialog_in_pages.pop_front())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Device.action_main) and input_allowed:
		if current_dialog_words.size() != 0:
			dialog_speed_modifier = 10

		else:
			if dialog_in_pages.size() != 0:
				_new_dialog_page(dialog_in_pages.pop_front())

			elif page_type_in_wait != 0:
				dialog_bubble.set_visible(false)
				question_text.set_bbcode(tr(current_dialog_key + "_?"))
				question_bubble.set_visible(true)
				line_edit.grab_focus()

			elif current_dialog_keys.size() != 0:
					current_dialog_key = current_dialog_keys.pop_front()
					_load_new_dialog(current_dialog_key)
					_new_dialog_page(dialog_in_pages.pop_front())

			else:
				emit_signal("dialog_ended")
				queue_free()

	elif event.is_action_released(Device.action_main):
		dialog_speed_modifier = 1

func _load_new_dialog(dialog_key: String) -> void:
	var dialog_as_words: Array = tr(dialog_key).split(" ")
	var current_page = []
	var current_size = 0

	for word in dialog_as_words:
		if current_size + word.length() > dialog_character_limit:
			dialog_in_pages.append(current_page)
			current_page = []
			current_size = 0

		current_page.append(word)
		current_size += word.length()

	if current_page.size() > 0:
		dialog_in_pages.append(current_page)

func _new_dialog_page(dialog_page: Array) -> void:
	current_dialog_words.clear()

	for c in container.get_children():
		c.queue_free()

	for s in shadows_container.get_children():
		s.queue_free()

	current_dialog_words = dialog_page
	word_timer.start()

func _on_word_timeout() -> void:
	var stored_punctuation: String = ""
	var text_speed = dialog_speed * dialog_speed_modifier * 10
	
	if current_dialog_words.size() != 0:
		var display_word: String = current_dialog_words.pop_front()

		if "{" in display_word and "}" in display_word:
			var execution_array: Array = (display_word.replace("{", "").replace("}", "")).split(",")
			var function_name: String = execution_array.pop_front()

			for c in break_chars:
				if function_name.ends_with(c):
					function_name = function_name.rstrip(c)
					stored_punctuation = c

			match function_name:
				"speed":
					dialog_speed = float(execution_array[0])
					display_word = current_dialog_words.pop_front()

				"font":
					#ADD FONT TYPES HERE LATER
					match execution_array[0]:
						0: pass
						_: pass
					display_word = current_dialog_words.pop_front()

				"question":
					match execution_array[0]:
						"word":
							function_to_update = execution_array[1]
							page_type_in_wait = 1
						"date":
							function_to_update = execution_array[1]
							page_type_in_wait = 2
					display_word = ""

				"branch":
					branch_button_0.get_child(0).set_bbcode(tr(current_dialog_key + "_B0"))
					branch_button_0.set_visible(true)
					if Utility.tr_key_exists(current_dialog_key + "_B1"):
						branch_button_1.get_child(0).set_bbcode(tr(current_dialog_key + "_B1"))
						branch_button_1.set_visible(true)
					if Utility.tr_key_exists(current_dialog_key + "_B2"):
						branch_button_2.get_child(0).set_bbcode(tr(current_dialog_key + "_B2"))
						branch_button_2.set_visible(true)
					if Utility.tr_key_exists(current_dialog_key + "_B3"):
						branch_button_3.get_child(0).set_bbcode(tr(current_dialog_key + "_B3"))
						branch_button_3.set_visible(true)
					input_allowed = false
					branch_bubble.set_visible(true)
					branch_button_0.grab_focus()
					display_word = ""

				"bold":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[b]", "[/b]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"italics":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[i]", "[/i]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"underline":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[u]", "[/u]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"strikethrough":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[s]", "[/s]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"emote":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[img=32x32", "[/img]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"color":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[color=" + execution_array[0] + "]", "[/color]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"wave":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[shake rate=" + execution_array[0] + " level=" + execution_array[1] + "]", "[/shake]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"tornado":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[wave amp=" + execution_array[0] + " freq=" + execution_array[1] + "]", "[/wave]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"rainbow":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[rainbow freq=" + execution_array[0] + " sat=" + execution_array[1] + " val=" + execution_array[1] + "]", "[/rainbow]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"heart":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[heart scale=" + execution_array[0] + " freq=" + execution_array[1] + "]", "[/heart]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"jump":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[jump angle=" + execution_array[0] + "]", "[/jump]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"leet":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[leet]", "[/leet]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"nervous":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[nervous scale=" + execution_array[0] + " freq=" + execution_array[1], "[/nervous]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"rain":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[rain]", "[/rain]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"sparkle":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[sparkle c1=" + execution_array[0] + " c2=" +  execution_array[1] + "]", "[/sparkle]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"uwu":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[uwu]", "[/uwu]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"swear":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[swear]", "[/swear]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				"woo":
					if current_bbcode.size() > 0 and current_bbcode == ["", ""]:
						current_bbcode = ["[woo]", "[/woo]"]
					else:
						current_bbcode = ["", ""]
					display_word = current_dialog_words.pop_front()

				_:
					if Functions.has_method(function_name):
						display_word = Functions.call(function_name, execution_array)
					else:
						display_word = ""

		if display_word != "":
			if stored_punctuation != "":
				display_word = display_word + stored_punctuation
				stored_punctuation = ""
			
			var char_ghost_label: Label = Label.new()
			char_ghost_label.add_font_override("font", load(current_font))
			char_ghost_label.set_visible(false)
			char_ghost_label.set_text(display_word)
			container.add_child(char_ghost_label)

			var new_char_label: RichTextLabel = bbcode_transition_label.instance()
			new_char_label.add_font_override("normal_font", load(current_font))
			new_char_label.set_custom_minimum_size(char_ghost_label.get_size())
			char_ghost_label.queue_free()

			new_char_label.id = "word_" + str(current_word)
			new_char_label.animation_time = (1.0 / display_word.length()) * text_speed

			var label_text: String = "[bounce id=word_" + str(current_word) + "]" + current_bbcode[0] + current_color[0] + display_word + current_color[1] + current_bbcode[1] + "[/bounce]"
			new_char_label.set_bbcode(label_text)
			shadows_container.add_child(new_char_label.duplicate())

			current_word += 1

			container.add_child(new_char_label)
			new_char_label.fade_in()

			word_timer.set_wait_time((display_word.length() / text_speed) * 0.6)
			word_timer.start()

			if dialog_display_name != "":
				get_parent().play_sound_babble()

func _on_Button_button_down():
	_get_dialog_response(current_dialog_key + "_B0")
	branch_bubble.set_visible(false)
	input_allowed = true

func _on_Button2_button_down():
	_get_dialog_response(current_dialog_key + "_B1")
	branch_bubble.set_visible(false)
	input_allowed = true

func _on_Button3_button_down():
	_get_dialog_response(current_dialog_key + "_B2")
	branch_bubble.set_visible(false)
	input_allowed = true

func _on_Button4_button_down():
	_get_dialog_response(current_dialog_key + "_B3")
	branch_bubble.set_visible(false)
	input_allowed = true

func _on_LineEdit_text_entered(new_text):
	if !line_edit.get_text().empty():
		dialog_bubble.set_visible(true)
		question_bubble.set_visible(false)

		if function_to_update != "":
			Functions.call(function_to_update, new_text.strip_edges(true, true))
			function_to_update = ""
			line_edit.clear()

		_get_dialog_response(current_dialog_key)
		page_type_in_wait = 0

func _get_dialog_response(original_key: String) -> void:
	original_key = original_key + "_R"
	_load_new_dialog(original_key)
	_new_dialog_page(dialog_in_pages.pop_front())
