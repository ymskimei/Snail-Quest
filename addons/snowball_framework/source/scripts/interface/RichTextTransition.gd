extends RichTextLabel

export var id: String = "main"
export(float, 0.0, 1.0) var time: float = 0.0
export(float, 1.0, 32.0) var length: float = 8.0
export(float, 0.1, 2.0) var animation_time: float = 1.0 
export var reverse: bool = false
export var all_at_once: bool = false

func _ready() -> void:
	Utility.register_text_transition(self)

func _exit_tree() -> void:
	Utility.unregister_text_transition(self)

# Mostly needed for editor testing.
func _process(delta):
	if not id in Utility.text_transitions:
		Utility.register_text_transition(self)

func on_animation_finish(anim_name: String) -> void:
	match anim_name:
		"fade_in": prints("Faded in.", self.name)
		"fade_out": prints("Faded out.", self.name)

func get_t(char_index:int, allow_all_together:bool = true) -> float:
	if all_at_once and allow_all_together:
		return 1.0 - time
	else:
		var characters = get_total_character_count() + length
		if reverse:
			var t = (1.0 - time) * characters
			return 1.0 - clamp((char_index + length - t), 0.0, length) / length
		else:
			var t = time * characters
			return clamp((char_index + length - t), 0.0, length) / length
