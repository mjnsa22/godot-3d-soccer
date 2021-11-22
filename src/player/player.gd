extends KinematicBody


var mouse_sens = 1.0

var velocity: Vector3
var walk_speed := 5
var sprint_speed := 10
var jump_force := 10
var gravity := 0.2

var ball: RigidBody


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sens))
		$Camera.rotate_x(deg2rad(-event.relative.y * mouse_sens))
		$Camera.rotation.x = clamp($Camera.rotation.x, deg2rad(-90), deg2rad(90))
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(_delta: float) -> void:
	var direction := get_input_axis()
	velocity = calculate_velocity(velocity, direction)
	velocity = move_and_slide(velocity, Vector3.UP)


func get_input_axis() -> Vector3:
	var direction: Vector3

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction.y = 0
	direction = direction.normalized()
	direction.y = 1 if Input.is_action_just_pressed("jump") else -1

	return direction


func calculate_velocity(velocity: Vector3, direction: Vector3) -> Vector3:
	var sprinting = Input.is_action_pressed("sprint")
	velocity.x = direction.x * (sprint_speed if sprinting else walk_speed)
	velocity.z = direction.z * (sprint_speed if sprinting else walk_speed)

	velocity.y -= gravity
	if direction.y == 1 and is_on_floor():
		velocity.y = jump_force

	return velocity
