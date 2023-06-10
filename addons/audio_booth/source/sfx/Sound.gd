extends AudioStreamPlayer
class_name Sound

export var singleton := false
export(float, 1.0, 2.0) var random_volume := 1.0
export(Array, AudioStream) var streams := []

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
	sound.connect("finished", self, "_on_finished", [ sound ])
	get_tree().current_scene.add_child(sound)
	return sound

func _randomize(sound: Sound) -> void:
	if streams:
		streams.shuffle()
		sound.stream = streams[0]
	sound.volume_db = linear2db(db2linear(volume_db) * rand_range(random_volume, 2.0 - random_volume))

func _on_finished(sound: AudioStreamPlayer) -> void:
	emit_signal("finished")
	if not singleton:
		sound.queue_free()
