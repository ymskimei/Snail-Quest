extends Control

onready var default_selection: Control = $"%StartButton"
onready var anim_cam: AnimationPlayer = $World/SpringArm/AnimationPlayer
onready var anim_daisy: AnimationPlayer = $World/Daisy/AnimationPlayer
onready var anim_logo: AnimationPlayer = $World/MeshInstance/AnimationPlayer

onready var splash: RichTextLabel = $MarginContainer/HBoxContainer/LabelSplash
onready var version: RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelVersion
onready var info: RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LabelInfo

signal game_start

func _ready() -> void:
	set_title_splash()
	version.set_bbcode("[color=#EFEFEF] Version " + SB.game.info["version"])
	info.set_bbcode("[right][color=#EFEFEF] " + SB.game.info["author"])
	default_selection.grab_focus()
	anim_cam.play("CamTitleStart")
	anim_daisy.play("DaisyBlossom")
	anim_logo.play("GuiLogoAppear")
	yield(anim_daisy, "animation_finished")
	anim_cam.play("CamWobble")
	anim_daisy.play("DaisyWiggle")
	anim_logo.play("GuiLogoIdle")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		set_title_splash()

func _physics_process(_delta: float) -> void:
	var cam = $World/SpringArm
	#cam.rotation.x = lerp(cam.rotation.x, Input.get_action_strength("cam_up") / 3 - Input.get_action_strength("cam_down") / 3, 0.1)
	#.rotation.y = lerp(cam.rotation.y, Input.get_action_strength("cam_left") / 3 - Input.get_action_strength("cam_right") / 3, 0.1)
	#cam.translation.y = lerp(cam.translation.y, Input.get_action_strength("cam_up") * 0.1  - Input.get_action_strength("cam_down") * 0.1, 0.1)
	#cam.translation.x = lerp(cam.translation.x, Input.get_action_strength("cam_left") * 0.2 - Input.get_action_strength("cam_right") * 0.2, 0.1)

func _on_StartButton_pressed() -> void:
	SB.utility.audio.play_sfx(RegistryAudio.tone_success)
	var fade = $GuiTransition/AnimationPlayer
	fade.play("GuiTransitionFade")
	#anim.play("GuiLogoDisappear")
	yield(fade, "animation_finished")
	emit_signal("game_start")
	queue_free()

func _on_OptionsButton_pressed() -> void:
	var interface = SB.game.interface
	interface.get_menu(interface.blur, interface.options)

func set_title_splash() -> void:
	var splashes: Array = [
		"GUI_TITLE_SPLASH_0",
		"GUI_TITLE_SPLASH_1",
		"GUI_TITLE_SPLASH_2",
		"GUI_TITLE_SPLASH_3",
		"GUI_TITLE_SPLASH_4",
		"GUI_TITLE_SPLASH_5",
		"GUI_TITLE_SPLASH_6",
		"GUI_TITLE_SPLASH_7",
		"GUI_TITLE_SPLASH_8",
		"GUI_TITLE_SPLASH_9"
	]
	randomize()
	splash.set_bbcode("[tornado radius=3 freq=2][color=#FFF896]" + TranslationServer.translate(splashes[randi() % splashes.size()]))
