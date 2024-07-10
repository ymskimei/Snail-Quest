extends TextureButton

onready var file_name: RichTextLabel = $MarginContainer/VBoxContainer/FileName
onready var health: HBoxContainer = $MarginContainer/VBoxContainer/Health
onready var currency: HBoxContainer = $MarginContainer/VBoxContainer/Currency
onready var time_and_location: RichTextLabel = $MarginContainer/VBoxContainer/TimeAndLocation
onready var play_time: RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/PlayTime
onready var last_played: RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/LastPlayed
onready var imitation_snail: PhysicsBody = $Viewport/Position3D/Snail

export var health_icon: PackedScene
export var health_empty: Texture

export var applied_data_file: int = 0

func _ready() -> void:
	var file = File.new()
	if file.file_exists("user://data/data " + str(applied_data_file) + "/save.sus"):
		var data: Array = Auto.data.get_data(Auto.data.get_data_folder(applied_data_file))
		imitation_snail.identity = data[1]
		file_name.set_bbcode(imitation_snail.identity.get_entity_name())
		time_and_location.set_bbcode(RegistryColor.get_bbcode(RegistryColor.light_gray) + Auto.utility.get_time_as_clock(data[0]["game_time"], false) + " in " + data[0]["location"])

		var current_health: int = data[0]["health"]
		var max_health: int = data[0]["max_health"]
		for n in max_health:
			health.add_child(health_icon.instance())
		currency.get_child(0).set_bbcode(str(data[0]["currency"]))

		play_time.set_bbcode("Total time " + Auto.utility.get_time_as_count(data[0]["play_time"]))
		last_played.set_bbcode(RegistryColor.get_bbcode(RegistryColor.light_gray) + "Last saved " + data[0]["last_played"])
	else:	
		file_name.set_bbcode("")
		time_and_location.set_bbcode("NO FILE")

		for h in health.get_children():
			h.set_texture(null)
		currency.get_child(0).set_bbcode("")
		currency.get_child(1).set_texture(null)

		play_time.set_bbcode("")
		last_played.set_bbcode("")

func _physics_process(delta: float) -> void:
	if self == get_focus_owner():
		imitation_snail.get_parent().rotation_degrees.y += 35 * delta
	else:
		imitation_snail.get_parent().rotation_degrees.y = 0
