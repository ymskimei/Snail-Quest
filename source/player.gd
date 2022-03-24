extends KinematicBody

var player_name = "Sheldon"
var player_speed = 7
var player_jump_power = 15
var player_gravity = 45
var velocity = Vector3.ZERO
var snap_vector = Vector3.DOWN
onready var spring_arm: SpringArm = $PlayerCameraArm
onready var model: Spatial = $PlayerModel

func _ready():
	print("Player name is " + player_name)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$Pause.pause()

func _physics_process(delta: float) -> void:
	var move_direction = Vector3.ZERO
	var player_landed = is_on_floor() and snap_vector == Vector3.ZERO
	var player_is_jumping = is_on_floor() and Input.is_action_just_pressed("ui_select")
	
	move_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	velocity.x = move_direction.x * player_speed
	velocity.z = move_direction.z * player_speed
	velocity.y -= player_gravity * delta
	
	if player_is_jumping:
		velocity.y = player_jump_power
		snap_vector = Vector3.ZERO
	elif player_landed:
		snap_vector = Vector3.DOWN
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	
	if velocity.length() > 0.2:
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = look_direction.angle() 

func _process(_delta: float) -> void:
	spring_arm.translation = translation
