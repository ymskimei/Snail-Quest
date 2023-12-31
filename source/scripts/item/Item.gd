class_name ItemParent
extends Spatial

export(Resource) var item

onready var mesh: Mesh
onready var material: Material
onready var item_body: RigidBody = $RigidBody
onready var proxy_path: Script

var sound: String = SnailQuest.audio.sfx_item_pickup

var tools = preload("res://assets/resource/pad_tools.tres")
var items = preload("res://assets/resource/inventory.tres")

var collecting : bool
var player : Spatial

export var collection_offset = Vector3(0, 1.5, 0)

var display_timer = Timer.new()
var idle_timer = Timer.new()

func _ready():
	$"%MeshInstance".set_mesh(item.mesh)
	item_body.set_bounce(0.5)
	if item.proxy_path != "":
		proxy_path = load(str(item.proxy_path))
	if item.sound != "":
		sound = item.sound
	display_timer.set_wait_time(1)
	display_timer.one_shot = true
	display_timer.connect("timeout", self, "on_display_timeout")
	idle_timer.set_wait_time(5)
	idle_timer.one_shot = true
	idle_timer.connect("timeout", self, "on_idle_timeout")
	add_child(display_timer)
	add_child(idle_timer)

func _physics_process(_delta):
	if collecting:
		item_body.translation = Vector3.ZERO
		translation = player.translation + collection_offset
	if item.depletable:
		idle_timer.start()
#	else:
#		body.collision

func _on_Area_body_entered(body):
	if body == SnailQuest.controllable and $RigidBody.linear_velocity == Vector3.ZERO:
		player = body
		display_timer.start()
		if item.depletable:
			Utility.item.add_item(items.items, item, 1)
		else:
			var slot = item.specific_slot
			Utility.item.set_item(tools.items, slot, item)
		SnailQuest.audio.play_sfx(sound)
		collecting = true
	pass

func on_display_timeout():
	collecting = false
	if proxy_path is Script:
		var proxy = Node.new()
		proxy.set_script(proxy_path)
		add_child(proxy)
		#proxy.connect("ended", self, "on_proxy_ended")
		#yield(proxy, "ended")
	queue_free()

func on_proxy_ended():
	pass

func on_idle_timeout():
	print("test")
	queue_free()

func random_velocity():
	$RigidBody.rotation_degrees = Vector3(0, rand_range(-180, 180), 0)
	$RigidBody.set_linear_velocity(Vector3(rand_range(-15, 15), rand_range(5, 15), rand_range(-15, 15)))
	print($RigidBody.linear_velocity)
