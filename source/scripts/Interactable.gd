class_name Interactable
extends RigidBody

export(Resource) var dialog

onready var anim: AnimationPlayer = $AnimationPlayer
onready var anim_tween: Tween = $Tween

var interaction_ended: bool
var character: bool

#func ready() -> void:
	#anim = get_node_or_null("AnimationPlayer")
	#anim_tween = get_node_or_null("Tween")

func get_coords(raw: bool = false) -> Vector3:
	var x = global_transform.origin.x
	var y = global_transform.origin.y
	var z = global_transform.origin.z
	if !raw:
		x = round(x)
		y = round(y)
		z = round(z)
	var coords = [x, y, z]
	return coords

func set_coords(position: Vector3, angle: String = "Default") -> void:
	set_global_translation(position)
	if !angle == "Default":
		set_global_rotation(Vector3(0, deg2rad(MathHelper.cardinal_to_degrees(angle)), 0))

func is_controlled() -> bool:
	if GlobalManager.controllable == self:
		return true
	return false

func get_interaction_text():
	return "interact"

func interact():
	pass

func interaction():
	print("Interacted with %s" % name)

func trigger_dialog() -> void:
	if !Dialogic.has_current_dialog_node():
		var text = dialog.dialogue_file
		print(text)
		var dialog_popup = Dialogic.start(text)
		dialog_popup.connect("dialogic_signal", self, "dialog_listener")
		add_child(dialog_popup)
		get_tree().set_deferred("paused", true)
		interaction_ended = false

func dialog_listener(string) -> void:
	match string:
		"dialog_ended":
			#AudioPlayer.play_sfx(sfx_sign_exit)
			get_tree().set_deferred("paused", false)
			interaction_ended = true
