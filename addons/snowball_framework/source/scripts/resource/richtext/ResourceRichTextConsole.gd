tool
extends RichTextTransition

var bbcode = "console"

const CURSOR = ord("█")
const CURSOR_COLOR = Color.greenyellow

var last_char = -1

func _process_custom_fx(char_fx):
	var tween_data = get_tween_data(char_fx)
	if tween_data.reverse:
		char_fx.offset.y -= 32 * (1.0 - tween_data.time)
		char_fx.color.a *= pow(tween_data.time, 8.0)
	else:
		if tween_data.time == 1.0:
			if char_fx.absolute_index == last_char and sin(char_fx.elapsed_time * 16.0) > 0.0:
				char_fx.character = CURSOR
				char_fx.color = CURSOR_COLOR
		else:
			if char_fx.relative_index == 0:
				last_char = -1
			var t1 = tween_data.get_t(char_fx.absolute_index, false)
			var t2 = tween_data.get_t(char_fx.absolute_index+1, false)
			if t1 > 0.0 and char_fx.character != SPACE:
				if t1 != t2:
					char_fx.character = CURSOR
					char_fx.color = CURSOR_COLOR
				else:
					char_fx.character = SPACE
			if char_fx.absolute_index > last_char:
				last_char = char_fx.absolute_index
	return true
