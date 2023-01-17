extends Node

export var root_path: NodePath
export var sfx_library = "res://assets/sound/"

onready var sound_effects = {
	"button_navigate": AudioStreamPlayer.new(),
	"button_select": AudioStreamPlayer.new(),
	"button_error": AudioStreamPlayer.new()
}

func _ready():
	assert(root_path != null, "Node path is empty")
	for file in sound_effects.keys():
		sound_effects[file].stream = load(sfx_library + str(file) + ".ogg")
		sound_effects[file].bus = "SFX"
		add_child(sound_effects[file])
#	load_sounds(get_node(root_path))
#
#func load_sounds(node: Node) -> void:
#	for option in node.get_children():
#		if option is Button:
#			option.is_hovered.connect(sfx_play("button_navigate"))
#			option.pressed.connect(sfx_play("button_select"))
#		load_sounds(option)

func sfx_play(sound: String) -> void:
	sound_effects[sound].play()
