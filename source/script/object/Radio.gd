extends KinematicBody

export var song: AudioStreamOGGVorbis
export var bpm: float = 0.0

onready var anim: AnimationPlayer = $AnimationPlayer

var speakers: AudioStreamPlayer3D

func _ready():
	if song != null:
		speakers = AudioStreamPlayer3D.new()
		speakers.set_stream(song)
		speakers.set_bus("Radio")
		add_child(speakers)
		speakers.set_unit_db(linear2db(4.0))
		speakers.set_max_distance(32.0)
		speakers.set_panning_strength(0.3)
		speakers.set_attenuation_filter_db(linear2db(1.0))
		speakers.play()
		#speakers.set_attenuation_filter_db(linear2db(0.1))
		#speakers.set_panning_strength(1.0)
		anim.play("Dance")
		anim.set_speed_scale(bpm / 120)
