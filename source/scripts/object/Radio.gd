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
		speakers.play()
		anim.play("Dance")
		anim.set_speed_scale(bpm / 120)
