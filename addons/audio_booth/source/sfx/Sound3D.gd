extends AudioStreamPlayer3D
class_name Sound3D

@export var singleton := false
@export var streams := [] # (Array, AudioStream)

var _sound: AudioStreamPlayer3D = null
var _is_initialized := false

func _ready() -> void:
	if _is_initialized:
		return
	if stream:
		streams.append(stream)
	_is_initialized = true

func play_at(_translation: Vector3, from_position := 0.0) -> void:
	if singleton:
		if not _sound:
			_sound = _get_sound(_translation)
			_randomize(_sound)
		_sound.transform.origin = _translation
		_sound.play()
	else:
		var sound = _get_sound(_translation)
		_randomize(sound)
		sound.play()

func _get_sound(_translation: Vector3) -> Sound3D:
	var sound = self.duplicate()
	sound.connect("finished", Callable(self, "_on_finished").bind(sound))
	get_tree().current_scene.add_child(sound)
	sound.transform.origin = _translation
	return sound

func _randomize(sound: Sound3D) -> void:
	if streams:
		streams.shuffle()
		sound.stream = streams[0]

func _on_finished(sound: AudioStreamPlayer3D) -> void:
	emit_signal("finished")
	if not singleton:
		sound.queue_free()
