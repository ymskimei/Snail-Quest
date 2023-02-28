class_name PrimaryCamera
extends SpringArm

onready var camera_target = $"/root/Game/Player"
onready var camera_lens = $CameraLens
onready var anim_tween = $CameraLens/Animation/AnimationCam
onready var anim_player = $CameraLens/Animation/AnimationPlayer
onready var audio_player = $WorldAudioPlayer
onready var states = $States

func _ready():
	states.ready(self)

func _physics_process(delta: float) -> void:
	states.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)
