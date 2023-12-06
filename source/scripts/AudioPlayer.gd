extends Node

onready var ambie_booth = $AmbieBooth
onready var sound_booth = $SoundBooth
onready var music_booth = $MusicBooth

#Ambience
const amb_overworld = "res://source/scenes/sound/amb_overworld.tscn"

#Sound Effects
const sfx_cam_zoom_normal = "res://assets/sound/sfx_cam_zoom_normal.ogg"
const sfx_cam_zoom_far = "res://assets/sound/sfx_cam_zoom_far.ogg"
const sfx_cam_perspective = "res://assets/sound/sfx_cam_perspective.ogg"
const sfx_cam_iso_up = "res://assets/sound/sfx_cam_iso_up.ogg"
const sfx_cam_iso_down = "res://assets/sound/sfx_cam_iso_down.ogg"
const sfx_cam_iso_rotate_0 = "res://assets/sound/sfx_cam_iso_rotate_0.ogg"
const sfx_cam_iso_rotate_1 = "res://assets/sound/sfx_cam_iso_rotate_1.ogg"
const sfx_cam_target_reset = "res://assets/sound/sfx_cam_target_reset.ogg"
const sfx_cam_target_lock = "res://assets/sound/sfx_cam_target_lock.ogg"
const sfx_cam_target_unlock = "res://assets/sound/sfx_cam_target_unlock.ogg"
const sfx_cam_no_target_lock = "res://assets/sound/sfx_cam_no_target_lock.ogg"
const sfx_cam_no_target_unlock = "res://assets/sound/sfx_cam_no_target_unlock.ogg"
const sfx_cam_first_person = "res://assets/sound/sfx_cam_first_person.ogg"
const sfx_cam_third_person = "res://assets/sound/sfx_cam_third_person.ogg"
const sfx_item_pickup = "res://assets/sound/sfx_item_pickup.ogg"
const sfx_bell_tone_next = "res://assets/sound/sfx_bell_tone_next.ogg"
const sfx_bell_tone_success = "res://assets/sound/sfx_bell_tone_success.ogg"
const sfx_bell_tone_error = "res://assets/sound/sfx_bell_tone_error.ogg"

#Positional Sound Effects
const sfx_snail_shell_in = "res://assets/sound/sfx_snail_shell_in.ogg"
const sfx_snail_shell_out = "res://assets/sound/sfx_snail_shell_out.ogg"
const sfx_needle_swipe_0 = "res://assets/sound/sfx_needle_swipe_0.ogg"
const sfx_needle_swipe_1 = "res://assets/sound/sfx_needle_swipe_1.ogg"
const sfx_needle_swipe_2 = "res://assets/sound/sfx_needle_swipe_2.ogg"
const sfx_mallet_charge_0 = "res://assets/sound/sfx_mallet_charge_0.ogg"
const sfx_mallet_charge_1 = "res://assets/sound/sfx_mallet_charge_1.ogg"
const sfx_mallet_charge_2 = "res://assets/sound/sfx_mallet_charge_2.ogg"
const sfx_mallet_slam = "res://assets/sound/sfx_mallet_slam.ogg"
const sfx_mallet_full_slam = "res://assets/sound/sfx_mallet_full_slam.ogg"
const sfx_switch_on = "res://assets/sound/sfx_switch_on.ogg"
const sfx_switch_off = "res://assets/sound/sfx_switch_off.ogg"
const sfx_door_open = "res://assets/sound/sfx_door_open.ogg"

#Soundtrack
const ost_snailytown = "res://source/scenes/sound/snaily_town.tscn"
const ost_layerstest = "res://source/scenes/sound/layers_test.tscn"

func init_ambience(path: String):
	var loops = load(path).instance()
	ambie_booth.add_child(loops)
	ambie_booth.reload_songs()

func init_song(path: String):
	var song = load(path).instance()
	music_booth.add_child(song)
	music_booth.reload_songs()

func play_sfx(path: String):
	var sfx = AudioStreamPlayer.new()
	var sound_effect = import_sound(path)
	sfx.stream = sound_effect
	sfx.set_volume_db(-8.0)
	sfx.set_bus("SFX")
	sound_booth.add_child(sfx)
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()

func play_pos_sfx(path: String, spatial: Vector3 = Vector3.ZERO):
	var sfx = AudioStreamPlayer3D.new()
	var sound_effect = import_sound(path)
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
