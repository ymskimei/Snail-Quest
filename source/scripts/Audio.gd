extends Node

onready var sound_booth: SoundBooth = $SoundBooth
onready var ambie_booth: MusicBooth = $AmbieBooth
onready var music_booth: MusicBooth = $MusicBooth

var sound_dir: String = "res://assets/sound/"

var sounds: Array = []
var ambience: Array = []
var music: Array = []

func _ready():
	print(sounds)

func init_ambience(path: String) -> void:
	var loops = load(path).instance()
	ambie_booth.add_child(loops)
	ambie_booth.reload_songs()

func init_song(path: String) -> void:
	var song = load(path).instance()
	music_booth.add_child(song)
	music_booth.reload_songs()

func get_current_track(song_name: String) -> AudioStreamPlayer:
	for n in music_booth.get_children():
		if n.name == song_name:
			var player: AudioStreamPlayer = n.get_child(0).get_child(0)
			return player
	return null

func play_sfx(file_name: String, pitch: float = 1.0, volume: float = 1.0) -> void:
	var sfx = AudioStreamPlayer.new()
	var sound_effect = get_sound(file_name)
	if sound_effect:
		sfx.set_stream(sound_effect)
		sfx.set_bus("SFX")
		sound_booth.add_child(sfx)
		sfx.set_pitch_scale(pitch)
		sfx.set_volume_db(linear2db(volume))
		sfx.play()
		yield(sfx, "finished")
		sfx.queue_free()

func play_pos_sfx(file_name: String, position: Vector3 = Vector3.ZERO, pitch: float = 1.0, volume: float = 1.0) -> void:
	var sfx = AudioStreamPlayer3D.new()
	var sound_effect = get_sound(file_name)
	if sound_effect:
		sfx.set_stream(sound_effect)
		sfx.set_unit_db(linear2db(volume))
		sfx.set_attenuation_filter_db(-16.0)
		sfx.set_attenuation_filter_cutoff_hz(16000.0)
		sfx.set_bus("SFX")
		sound_booth.add_child(sfx)
		sfx.set_pitch_scale(pitch)
		sfx.set_global_translation(position)
		sfx.play()
		yield(sfx, "finished")
		sfx.queue_free()

func get_sound(file_name: String) -> Sound:
	var full_path = sound_dir + file_name + ".ogg"
	var file = File.new()
	var ogg = AudioStreamOGGVorbis.new()
	file.open(full_path, File.READ)
	ogg.data = file.get_buffer(file.get_len())
	file.close()
	return ogg
