extends Node

var song_position = 0.0
var song_position_in_beats = 1
var sec_per_beat = 60.0
var last_reported_beat = 0
var beats_before_start = 0
var measure = 1
var song_length = 0
var timer = Timer.new()

signal beat(position)
signal measure(position)

func _ready():
	bpm = resource.bpm
	measures = resource.measures
	bars = resource.bars
	sec_per_beat = 60.0 / bpm
	song_length = (60 * measures * bars) / bpm
	timer.connect("timeout", self,"_on_timeout")
	timer.wait_time = bpm / 60
	timer.one_shot = true
	add_child(timer)

func play_main():
	play()
	timer.start()

func _physics_process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position)) + beats_before_start
		if get_playback_position() >= song_length:
			seek(0)
		emit_beat()
		print(measure)

func play_from_beat(beat, offset):
	play()
	seek(beat * sec_per_beat)
	beats_before_start = offset
	measure = beat % measures

func _on_timeout():
	print("beat")
	song_position_in_beats += 1
	if song_position_in_beats < beats_before_start - 1:
		timer.start()
	elif song_position_in_beats == beats_before_start - 1:
		timer.wait_time = timer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		timer.start()
	else:
		play()
		timer.stop()
	emit_beat()

func emit_beat():
	if last_reported_beat < song_position_in_beats:
		if measure >= measures:
			measure = 0
		emit_signal("beat", song_position_in_beats)
		emit_signal("measure", measure)
		last_reported_beat = song_position_in_beats
		measure += 1

#onready var battle_music_layer_1 = $Soundtrack/MusicTest/BattleMusicLayer1
#onready var battle_music_layer_2 = $Soundtrack/MusicTest/BattleMusicLayer2
#onready var battle_music_layer_3 = $Soundtrack/MusicTest/BattleMusicLayer3
#
#var battle_drums = false
#
#func _process(delta):
#	battle_drums = false
#
#func play_battle_drums_far():
#	if battle_drums == true and !battle_music_layer_1.playing:
#			battle_music_layer_2.volume_db = 0.0
#
#func stop_battle_drums_far():
#	if battle_drums == true and !battle_music_layer_1.playing:
#			battle_music_layer_2.volume_db = -80.0
#
#func play_battle_drums_near():
#	if battle_drums == true and !battle_music_layer_1.playing:
#			battle_music_layer_3.volume_db = 0.0
#
#func stop_battle_drums_near():
#	if battle_drums == true and! battle_music_layer_1.playing:
#			battle_music_layer_3.volume_db = -80.0
#
#func _on_BattleMusicLayer1_measure(position):
#	battle_drums = true
