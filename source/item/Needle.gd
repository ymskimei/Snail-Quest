extends RigidBody

onready var anim = $AnimationPlayer
var stored_attacks = 0

func _ready():
	anim.connect("animation_finished", self, "on_animation_finished")

func _physics_process(delta):
	directional_swing()
	combo_swing()

func combo_swing():
	if Input.is_action_just_released("action_combat"):
		$"%Particles".emitting = true
		if stored_attacks == 0:
			AudioPlayer.play_sfx(AudioPlayer.sfx_needle_swipe_0)
			anim.play_backwards("NeedleSwingHorizontal")
			stored_attacks = 1
		elif stored_attacks == 1:
			AudioPlayer.play_sfx(AudioPlayer.sfx_needle_swipe_1)
			anim.play("NeedleSwingVertical")
			stored_attacks = 2
		elif stored_attacks >= 2:
			AudioPlayer.play_sfx(AudioPlayer.sfx_needle_swipe_2)
			anim.play("NeedleSwingHorizontal")
			stored_attacks = 0
		print(stored_attacks)

func directional_swing():
	if !GlobalManager.player.targeting:
		if Input.is_action_pressed("action_combat"):
			$"%Particles".emitting = true
			rotation.y = clamp(lerp(rotation.y, (Input.get_action_raw_strength("ui_left") - Input.get_action_raw_strength("ui_right")) * 1.5, 0.4), deg2rad(-90), deg2rad(90))
			rotation.x = clamp(lerp(rotation.x, (Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")) * 1.5, 0.2), deg2rad(-45), deg2rad(90))
		else:
			make_stationary()
	else:
		if Input.is_action_pressed("cam_left") or Input.is_action_pressed("cam_right") or Input.is_action_pressed("cam_up") or Input.is_action_pressed("cam_down"):
			$"%Particles".emitting = true
			rotation.y = clamp(lerp(rotation.y, (Input.get_action_raw_strength("cam_left") - Input.get_action_raw_strength("cam_right")) * 1.5, 0.4), deg2rad(-90), deg2rad(90))
			rotation.x = clamp(lerp(rotation.x, (Input.get_action_raw_strength("cam_down") - Input.get_action_raw_strength("cam_up")) * 1.5, 0.2), deg2rad(-45), deg2rad(90))
		else:
			make_stationary()

func make_stationary():
	$"%Particles".emitting = false
	rotation.y = lerp(rotation.y, 0, 0.2)
	rotation.x = lerp(rotation.x, 0, 0.2)

func _on_AnimationPlayer_animation_finished(anim_name):
	make_stationary()
