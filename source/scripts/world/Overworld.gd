extends Node

var m_booth = AudioPlayer.music_booth
var a_booth = AudioPlayer.ambie_booth

var enemy_near : bool
var enemy_pursuing : bool

func _ready():
	overworld_ambience()

func overworld_ambience():
	AudioPlayer.init_ambience(AudioPlayer.amb_overworld)
	a_booth.play_song("Overworld", 1.0)

func get_percentage(value: float, min_y: float, max_y: float) -> float:
	var percentage = clamp(value, min_y, max_y)
	return (percentage - min_y) / (max_y - min_y)

func lerp_gain(percentage: float, min_gain: float, max_gain: float) -> float:
	return min_gain + (max_gain - min_gain) * percentage

func set_ambience_eq():
	var y_max = 512
	var y_min = -256
	var audio_listener = GlobalManager.camera.camera_lens.get_global_translation().y
	var amount = clamp((audio_listener - y_min) / (y_max - y_min), 0, 1)
	var hz_32 = lerp(-1.0, -16.0, amount)
	var hz_100 = lerp(2.0, -4.0, amount)
	var hz_320 = lerp(-13.0, 22.0, amount)
	var hz_1000 = lerp(-16.0, 0.0, amount)
	var hz_3200 = lerp(-2.0, -4.5, amount)
	var hz_10000 = lerp(-28.0, 5.0, amount)
	var effect: AudioEffectEQ = AudioServer.get_bus_effect(AudioServer.get_bus_index("Ambience"), 0)
	effect.set_band_gain_db(0, hz_32)
	effect.set_band_gain_db(1, hz_100)
	effect.set_band_gain_db(2, hz_320)
	effect.set_band_gain_db(3, hz_1000)
	effect.set_band_gain_db(4, hz_3200)
	effect.set_band_gain_db(5, hz_10000)

	#Outside
#	effect.set_band_gain_db(0, 20.0)
#	effect.set_band_gain_db(1, -17.0)
#	effect.set_band_gain_db(2, -23.5)
#	effect.set_band_gain_db(3, -22.0)
#	effect.set_band_gain_db(4, -50)
#	effect.set_band_gain_db(5, -60.0)

func _physics_process(delta):
	set_ambience_eq()
#	if GlobalManager.player.near_enemy:
#		if m_booth.is_song_playing("LayersTest"):
#			m_booth.play_track(2, 5.0)
#			m_booth.play_track(3, 5.0)
#	else:
#		if m_booth.is_song_playing("LayersTest"):
#			m_booth.stop_track(2, 5.0)
#			m_booth.stop_track(3, 5.0)

func _on_SnailyTown_body_entered(body):
	if body is Player:
		AudioPlayer.init_song(AudioPlayer.ost_layerstest)
		m_booth.play_song("LayersTest", 5.0)
		m_booth.play_track(1, 5.0)

func _on_SnailyTown_body_exited(body):
	if body is Player:
		m_booth.stop_song(5.0)
