class_name ObjectInteractable
extends ObjectParent

export(Resource) var dialog

var sfx_sign_view = preload("res://assets/sound/sfx_sign_view.ogg")
var sfx_sign_exit = preload("res://assets/sound/sfx_sign_exit.ogg")

var interaction_ended: bool

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
