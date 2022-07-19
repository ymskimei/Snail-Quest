extends SpringArm

export var mouse_sensitivity = 0.1
export var controller_sensitivity = 2

func _ready() -> void:
	set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	print("Camera test")
	apply_controller_rotation()
	self.rotation.x = clamp(self.rotation.x, deg2rad(-75), deg2rad(75))

func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			self.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))

func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	if InputEventJoypadMotion:
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		self.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity / 1.3)
