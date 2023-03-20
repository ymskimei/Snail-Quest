class_name ItemParent
extends Spatial

export(Resource) var item

onready var mesh : Mesh
onready var material : Material
	
var tools = preload("res://resource/tools.tres")

var collecting : bool
var player : Spatial

export var collection_offset = Vector3(0, 1.5, 0)

var timer = Timer.new()

func _ready():
	$"%MeshInstance".set_mesh(item.mesh)
	$AnimationPlayer.play("Floating")
	$AnimationPlayer.seek(rand_range(0, 1))
	timer.set_wait_time(1)
	timer.one_shot = true
	timer.connect("timeout", self, "on_timeout")
	add_child(timer)

func _physics_process(delta):
	if collecting:
		$AnimationPlayer.play("Still")
		translation = player.translation + collection_offset

func _on_Area_body_entered(body):
	if body is Player:
		player = body
		timer.start()
		tools.add_item(item, 1)
		AudioPlayer.play_sfx(AudioPlayer.sfx_item_pickup_test)
		collecting = true

func on_timeout():
	collecting = false
	queue_free()
