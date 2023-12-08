extends Node

var bpm = 120
var sig = 4
var length = 76

var beat = 0
var bar = 0

var track_test_0 = AudioPlayer.ost_snailytown_perc_day
var track_test_1 = AudioPlayer.ost_snailytown_bass_day

func _ready():
	add_track_timers()
	play_channel_0()

func play_channel_0():
	add_track_instance(track_test_0)
	add_track_instance(track_test_1)	

func add_track_instance(track):
	var channel = AudioStreamPlayer.new()
	channel.stream = track
	add_child(channel)
	channel.play()
	yield(channel, "finished")
	channel.queue_free()

func add_track_timers():
	var beat_timer = Timer.new()
	var bar_timer = Timer.new()
	var loop_timer = Timer.new()
	beat_timer.set_wait_time((bpm / 60) / sig)
	beat_timer.connect("timeout", self, "on_beat_timeout")
	add_child(beat_timer)
	bar_timer.set_wait_time(bpm / 60)
	bar_timer.connect("timeout", self, "on_bar_timeout")
	add_child(bar_timer)
	loop_timer.set_wait_time((bpm / 60) * length)
	loop_timer.connect("timeout", self, "on_end_timeout")
	add_child(loop_timer)
	return_bar()
	return_beat()
	beat_timer.start()
	bar_timer.start()
	loop_timer.start()

func on_beat_timeout():
	return_beat()

func on_bar_timeout():
	return_bar()
	beat = 0

func on_end_timeout():
	bar = 0
	print("LOOP")
	play_channel_0()

func return_beat():
	beat += 1
	print("Beat #" + str(beat))

func return_bar():
	bar += 1
	print("Bar #" + str(bar))

#export(Resource) var resource
#
#onready var track_0 = $Track0
#
#var track_position = 0.0
#var track_beat = 1
#var sec_per_beat = 60.0
#var last_beat = 0
#var start_beat = 0
#var measure = 1
#var track_length = 0
#var timer = Timer.new()
#
#var bpm = 0
#var measures = 0
#var bars = 0
#var song_length = 0
#
#signal beat(position)
#signal measure(position)
#
#func _ready():
#	bpm = resource.bpm
#	measures = resource.measures
#	bars = resource.bars
#	sec_per_beat = 60.0 / bpm
#	song_length = (60 * measures * bars) / bpm
#	timer.connect("timeout", self,"_on_timeout")
#	timer.wait_time = bpm / 60
#	timer.one_shot = true
#	add_child(timer)
#
#func play_main():
#	track_0.play()
#	timer.start()
#
#func _physics_process(_delta):
#	if track_0.playing:
#		track_position = track_0.get_playback_position() + AudioServer.get_time_since_last_mix()
#		track_position -= AudioServer.get_output_latency()
#		track_beat = int(floor(track_position)) + start_beat
#		if track_0.get_playback_position() >= track_length:
#			track_0.seek(0)
#		emit_beat()
#		print(measure)
#
#func play_from_beat(beat, offset):
#	track_0.play()
#	track_0.seek(beat * sec_per_beat)
#	start_beat = offset
#	measure = beat % measures
#
#func _on_timeout():
#	print("beat")
#	track_beat += 1
#	if track_beat < start_beat - 1:
#		timer.start()
#	elif track_beat == start_beat - 1:
#		timer.wait_time = timer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
#		timer.start()
#	else:
#		track_0.play()
#		timer.stop()
#	emit_beat()
#
#func emit_beat():
#	if last_beat < track_beat:
#		if measure >= measures:
#			measure = 0
#		emit_signal("beat", track_beat)
#		emit_signal("measure", measure)
#		last_beat = track_beat
#		measure += 1
