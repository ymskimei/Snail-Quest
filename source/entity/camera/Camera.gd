class_name MainCamera
extends SpringArm

onready var player = get_parent().get_node("Player")
onready var camera_lens = $CameraLens
onready var anim_tween = $Animation/AnimationCam
onready var anim_player = $Animation/AnimationPlayer
onready var states = $StateController

func _ready():
	states.ready(self)

func _physics_process(delta: float) -> void:
	states.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	states.unhandled_input(event)
