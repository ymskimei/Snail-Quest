class_name Item
extends Spatial

export var type: Resource

onready var item: RigidBody = $RigidBody
onready var mesh: MeshInstance = $RigidBody/MeshInstance
onready var anim: AnimationPlayer = $AnimationPlayer

var collecting: bool
var player: Spatial

var display_timer: Timer = Timer.new()
var idle_timer: Timer = Timer.new()

func _ready() -> void:
	mesh.set_mesh(type.mesh)
	_init_timers()
	_randomize_animation()

func _physics_process(_delta: float) -> void:
	if collecting:
		item.translation = Vector3.ZERO
		var collection_offset =  Vector3(0, player.body.get_aabb().size.y + 0.2, 0)
		translation = player.translation + collection_offset
		anim.play("ItemCollect")
	if type.depletable:
		idle_timer.start()

func _on_Area_body_entered(body):
	if body == SB.controllable and item.linear_velocity == Vector3.ZERO:
		player = body
		display_timer.start()
		if type.destination:
			var resource = type.destination
			if !type.depletable:
				SB.utility.item.add_item(resource.items, type, 1)
			else:
				var slot = type.specific_slot
				SB.utility.item.set_item(resource.items, slot, type)
		if type.sound != "":
			SB.utility.audio.play_sfx(type.sound)
		collecting = true

func _randomize_animation() -> void:
	anim.play("ItemBounce")
#	randomize()
#	var rand_pos = rand_range(0, float(anim.current_animation_position))
#	anim.seek(rand_pos)

func randomize_velocity():
	item.rotation_degrees = Vector3(0, rand_range(-180, 180), 0)
	item.set_linear_velocity(Vector3(rand_range(-15, 15), rand_range(5, 15), rand_range(-15, 15)))

func _init_timers():
	display_timer.set_wait_time(1)
	display_timer.one_shot = true
	display_timer.connect("timeout", self, "_on_display_timeout")
	add_child(display_timer)
	idle_timer.set_wait_time(5)
	idle_timer.one_shot = true
	idle_timer.connect("timeout", self, "_on_idle_timeout")
	add_child(idle_timer)

func _on_display_timeout():
	collecting = false
	if type.proxy_path != "":
		var path = load(str(type.proxy_path))
		if path is Script:
			var proxy = Node.new()
			proxy.set_script(path)
			add_child(proxy)
	queue_free()

func _on_idle_timeout():
	queue_free()
