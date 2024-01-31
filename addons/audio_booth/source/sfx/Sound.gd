extends AudioStreamPlayer
class_name Sound

@export var singleton := false
@export var random_volume := 1.0 # (float, 1.0, 2.0)
@export var streams := [] # (Array, AudioStream)

var _sound: AudioStreamPlayer = null
var _is_initialized := false

func _ready() -> void:
	if _is_initialized:
		return
	if stream:
		streams.append(stream)
	_is_initialized = true

func play_sfx(from_position := 0.0) -> void:
	if singleton:
		if not _sound:
			_sound = _get_sound()
		_randomize(_sound)
		_sound.play()
	else:
		var sound = _get_sound()
		_randomize(sound)
		sound.play()

func _get_sound() -> Sound:
	var sound = self.duplicate()
	sound.connect("finished", Callable(self, "_on_finished").bind(sound))
	get_tree().current_scene.add_child(sound)
	return sound

func _randomize(sound: Sound) -> void:
	if streams:
		streams.shuffle()
		sound.stream = streams[0]
	sound.volume_db = linear_to_db(db_to_linear(volume_db) * randf_range(random_volume, 2.0 - random_volume))

func _on_finished(sound: AudioStreamPlayer) -> void:
	emit_signal("finished")
	if not singleton:
		sound.queue_free()
