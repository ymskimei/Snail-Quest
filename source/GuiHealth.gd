extends RichTextLabel

onready var player_node = get_owner()

func _process(delta):
	set_text("Health: " + str(player_node.get("_player_health")))
