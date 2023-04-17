extends Node

var sfx_cam_zoom_normal = preload("res://assets/sound/sfx_cam_zoom_normal.ogg")
var sfx_cam_zoom_far = preload("res://assets/sound/sfx_cam_zoom_far.ogg")
var sfx_cam_perspective = preload("res://assets/sound/sfx_cam_perspective.ogg")
var sfx_cam_iso_up = preload("res://assets/sound/sfx_cam_iso_up.ogg")
var sfx_cam_iso_down = preload("res://assets/sound/sfx_cam_iso_down.ogg")
var sfx_cam_iso_rotate_0 = preload("res://assets/sound/sfx_cam_iso_rotate_0.ogg")
var sfx_cam_iso_rotate_1 = preload("res://assets/sound/sfx_cam_iso_rotate_1.ogg")
var sfx_cam_target_lock = preload("res://assets/sound/sfx_cam_target_lock.ogg")
var sfx_cam_target_unlock = preload("res://assets/sound/sfx_cam_target_unlock.ogg")
var sfx_cam_first_person = preload("res://assets/sound/sfx_cam_first_person.ogg")
var sfx_cam_third_person = preload("res://assets/sound/sfx_cam_third_person.ogg")

var sfx_item_pickup_test = preload("res://assets/sound/sfx_item_pickup_test.ogg")

var sfx_snail_shell_in = preload("res://assets/sound/sfx_snail_shell_in.ogg")
var sfx_snail_shell_out = preload("res://assets/sound/sfx_snail_shell_out.ogg")

var sfx_needle_swipe_0 = preload("res://assets/sound/sfx_needle_swipe_0.ogg")
var sfx_needle_swipe_1 = preload("res://assets/sound/sfx_needle_swipe_1.ogg")
var sfx_needle_swipe_2 = preload("res://assets/sound/sfx_needle_swipe_2.ogg")

func play_sfx(sound):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = sound
	add_child(sfx)
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()
