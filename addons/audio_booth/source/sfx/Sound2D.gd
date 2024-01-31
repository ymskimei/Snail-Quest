extends AudioStreamPlayer2D
class_name Sound2D

@export var singleton := false
@export var random_volume := 1.0 # (float, 1.0, 2.0)
@export var streams := [] # (Array, AudioStream)

var _sound: AudioStreamPlayer2D = null
var _is_initialized := false

func _ready() -> void:
	if _is_initialized:
		return
	if stream:
		streams.append(stream)
	_is_initialized = true

func play_at(_position: Vector2, from_position := 0.0) -> void:
	if singleton:
		if not _sound:
			_sound = _get_sound(_position)
		_randomize(_sound)
		_sound.position = _position
		_sound.play()
	else:
		var sound = _get_sound(_position)
		_randomize(sound)
		sound.play()

func _get_sound(_position: Vector2) -> Sound2D:
	var sound = self.duplicate()
	sound.connect("finished", Callable(self, "_on_finished").bind(sound))
	get_tree().current_scene.add_child(sound)
	sound.position = _position
	return sound

func _randomize(sound: Sound2D) -> void:
	if streams:
		streams.shuffle()
		sound.stream = streams[0]
	sound.volume_db = linear_to_db(db_to_linear(volume_db) * randf_range(random_volume, 2.0 - random_volume))

func _on_finished(sound: AudioStreamPlayer2D) -> void:
	emit_signal("finished")
	if not singleton:
		sound.queue_free()
