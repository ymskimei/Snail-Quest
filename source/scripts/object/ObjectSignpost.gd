extends ObjectInteractable

export(Resource) var resource
#onready var text : String

var sfx_sign_view = preload("res://assets/sound/sfx_sign_view.ogg")
var sfx_sign_exit = preload("res://assets/sound/sfx_sign_exit.ogg")

var interaction_ended : bool

func _ready():
	pass

func get_interaction_text():
	return "read sign"

func interact():
	if !Dialogic.has_current_dialog_node():
		#AudioPlayer.play_sfx(sfx_sign_view)
		var text = resource.dialogue_file
		print(text)
		var dialogue = Dialogic.start(text)
		dialogue.connect("dialogic_signal", self, "dialog_listener")
		add_child(dialogue)
		get_tree().set_deferred("paused", true)
		interaction_ended = false

func dialog_listener(string):
	match string:
		"dialogue_ended":
			#AudioPlayer.play_sfx(sfx_sign_exit)
			get_tree().set_deferred("paused", false)
			interaction_ended = true

