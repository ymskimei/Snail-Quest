extends Node

onready var sound_booth = $SoundBooth
onready var ambie_booth = $AmbieBooth
onready var music_booth = $MusicBooth

var sfx_cam_zoom_normal = "res://assets/sound/sfx_cam_zoom_normal.ogg"
var sfx_cam_zoom_far = "res://assets/sound/sfx_cam_zoom_far.ogg"
var sfx_cam_perspective = "res://assets/sound/sfx_cam_perspective.ogg"
var sfx_cam_iso_up = "res://assets/sound/sfx_cam_iso_up.ogg"
var sfx_cam_iso_down = "res://assets/sound/sfx_cam_iso_down.ogg"
var sfx_cam_iso_rotate_0 = "res://assets/sound/sfx_cam_iso_rotate_0.ogg"
var sfx_cam_iso_rotate_1 = "res://assets/sound/sfx_cam_iso_rotate_1.ogg"
var sfx_cam_target_reset = "res://assets/sound/sfx_cam_target_reset.ogg"
var sfx_cam_target_lock = "res://assets/sound/sfx_cam_target_lock.ogg"
var sfx_cam_target_unlock = "res://assets/sound/sfx_cam_target_unlock.ogg"
var sfx_cam_no_target_lock = "res://assets/sound/sfx_cam_no_target_lock.ogg"
var sfx_cam_no_target_unlock = "res://assets/sound/sfx_cam_no_target_unlock.ogg"
var sfx_cam_first_person = "res://assets/sound/sfx_cam_first_person.ogg"
var sfx_cam_third_person = "res://assets/sound/sfx_cam_third_person.ogg"
var sfx_item_pickup = "res://assets/sound/sfx_item_pickup.ogg"
var sfx_snail_shell_in = "res://assets/sound/sfx_snail_shell_in.ogg"
var sfx_snail_shell_out = "res://assets/sound/sfx_snail_shell_out.ogg"
var sfx_needle_swipe_0 = "res://assets/sound/sfx_needle_swipe_0.ogg"
var sfx_needle_swipe_1 = "res://assets/sound/sfx_needle_swipe_1.ogg"
var sfx_needle_swipe_2 = "res://assets/sound/sfx_needle_swipe_2.ogg"
var sfx_mallet_charge_0 = "res://assets/sound/sfx_mallet_charge_0.ogg"
var sfx_mallet_charge_1 = "res://assets/sound/sfx_mallet_charge_1.ogg"
var sfx_mallet_charge_2 = "res://assets/sound/sfx_mallet_charge_2.ogg"
var sfx_mallet_slam = "res://assets/sound/sfx_mallet_slam.ogg"
var sfx_mallet_full_slam = "res://assets/sound/sfx_mallet_full_slam.ogg"

var ost_snailytown_bass_day = "res://assets/sound/music/snaily_town/ost_snailytown_bass_day.ogg"
var ost_snailytown_perc_day = "res://assets/sound/music/snaily_town/ost_snailytown_perc_day.ogg"

func play_sfx(sound: String):
	var sfx = AudioStreamPlayer.new()
	var sound_effect = import_sound(sound)
	sfx.stream = sound_effect
	sfx.set_volume_db(-8.0)
	sfx.set_bus("SFX")
	sound_booth.add_child(sfx)
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()

func play_pos_sfx(sound: String, spatial: Vector3):
	var sfx = AudioStreamPlayer3D.new()
	var sound_effect = import_sound(sound)
	sfx.stream = sound_effect
	sfx.set_unit_db(8.0)
	sfx.set_attenuation_filter_db(-16.0)
	sfx.set_attenuation_filter_cutoff_hz(16000.0)
	sfx.set_bus("SFX")
	sound_booth.add_child(sfx)
	sfx.global_translation = spatial
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()

func import_sound(path: String):
	var file = File.new()
	var ogg = AudioStreamOGGVorbis.new()
	file.open(path, File.READ)
	ogg.data = file.get_buffer(file.get_len())
	file.close()
	return ogg
