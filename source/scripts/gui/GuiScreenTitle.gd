extends Control

onready var default_selection = $"%StartButton"
onready var screen_options = $GuiOptions
onready var anim = $World/MeshInstance/AnimationLogo

signal game_start

func _ready():
	default_selection.grab_focus()
	anim.play("GuiLogoAppear")
	yield(anim, "animation_finished")
	anim.play("GuiLogoIdle")

func _physics_process(delta):
	var cam = $World/SpringArm
	cam.rotation.x = lerp(cam.rotation.x, Input.get_action_strength("cam_up") / 3 - Input.get_action_strength("cam_down") / 3, 0.1)
	cam.rotation.y = lerp(cam.rotation.y, Input.get_action_strength("cam_left") / 3 - Input.get_action_strength("cam_right") / 3, 0.1)
	cam.translation.y = lerp(cam.translation.y, Input.get_action_strength("cam_up") * 0.1  - Input.get_action_strength("cam_down") * 0.1, 0.1)
	cam.translation.x = lerp(cam.translation.x, Input.get_action_strength("cam_left") * 0.2 - Input.get_action_strength("cam_right") * 0.2, 0.1)

func _on_StartButton_pressed():
	var fade = $GuiTransition/AnimationPlayer
	fade.play("GuiTransitionFade")
	anim.play("GuiLogoDisappear")
	yield(fade, "animation_finished")
	emit_signal("game_start")
	queue_free()

func _on_OptionsButton_pressed():
	screen_options.popup_centered()
