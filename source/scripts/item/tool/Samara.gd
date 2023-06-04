extends KinematicBody

export(Resource) var resource

export var speed = 20

var player_loc : Vector3
var returning : bool

func _ready():
	
	var player_loc = get_direction()
	var timer = Timer.new()
	timer.set_wait_time(0.3)
	timer.connect("timeout", self, "on_timeout")
	timer.one_shot = true
	add_child(timer)
	returning = false
	timer.start()

func _physics_process(delta):
	$MeshInstance.rotation.y += 20 * delta
	if is_instance_valid(GlobalManager.player):
		if returning:
			global_translation = lerp(global_translation, GlobalManager.player.global_translation, speed * delta)
		else:
			var direction = GlobalManager.player.global_transform.basis.z.normalized()
			global_translation = lerp(global_translation, direction * speed, delta)
	
func get_direction() -> Vector3:
	var direction = GlobalManager.player.transform.basis.xform(Vector3(0, 0, -1))
	return direction.normalized()

func _on_Area_body_entered(body):
	if body is Player and returning:
		GlobalManager.player.equipped.set_item(0, resource)
		queue_free()

func on_timeout():
	print("return")
	returning = true
