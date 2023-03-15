extends Interactable

export(Resource) var resource
#onready var text : String

var sfx_sign_view = preload("res://assets/sound/sfx_sign_view.ogg")
var sfx_sign_exit = preload("res://assets/sound/sfx_sign_exit.ogg")

func _ready():
	pass

func get_interaction_text():
	return "read sign"

func interact():
	if !Dialogic.has_current_dialog_node():
		var sfx = AudioStreamPlayer.new()
		sfx.stream = sfx_sign_view
		add_child(sfx)
		sfx.play()
		var text = resource.dialogue_file
		print(text)
		var dialogue = Dialogic.start(text)
		dialogue.connect("dialogic_signal", self, "dialog_listener")
		add_child(dialogue)
		get_tree().set_deferred("paused", true)

func dialog_listener(string):
	match string:
		"dialogue_ended":
			var sfx = AudioStreamPlayer.new()
			sfx.stream = sfx_sign_exit
			add_child(sfx)
			sfx.play()
			get_tree().set_deferred("paused", false)

