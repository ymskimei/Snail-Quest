tool
extends RichTextLabel

onready var animation_player: AnimationPlayer = $AnimationPlayer

export(String) var id: String = "main"

export(float, 0.0, 1.0) var time: float = 0.0
export(float, 1.0, 32.0) var length: float = 8.0

export(bool) var reverse:bool = false
export(bool) var all_at_once:bool = false

export(float, 0.1, 2.0) var animation_time: float = 1.0 

func _enter_tree():
	Utility.register(self)

func _exit_tree():
	Utility.unregister(self)

func _process(_delta: float) -> void:
	if not id in Utility.transitions:
		Utility.register(self)

func fade_in() -> void:
	animation_player.play("bb_fade_in", -1, animation_time)

func fade_out() -> void:
	animation_player.play("bb_fade_out", -1, animation_time)

func get_t(char_index: int, allow_all_together: bool = true) -> float:
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
