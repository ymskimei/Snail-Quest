extends Path

onready var anim = $AnimationPlayer

var to_timer = Timer.new()
var from_timer = Timer.new()

func _ready():
	anim.play("Movement")
