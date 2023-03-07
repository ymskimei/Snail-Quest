class_name AudioStreamMusic
extends AudioStreamPlayer

export(Resource) var resource

onready var bpm : int
onready var measures : int
onready var bars : int

signal beat(position)
signal measure(position)

func _ready():
	bpm = resource.bpm
	measures = resource.measures
	bars = resource.bars

#extends Node
#
#onready var music = $MixingDeskMusic
#
#func _ready():
#	music.init_song("Demo")
#	music.play("Demo")
#
#func play_battle_music():
#		music.unmute("Demo", "Bass")
#		music.unmute("Demo", "Percussion1")
#		music.unmute("Demo", "Percussion2")
#
#func stop_battle_music():
#		music.mute("Demo", "Bass")
#		music.mute("Demo", "Percussion1")
#		music.mute("Demo", "Percussion2")
