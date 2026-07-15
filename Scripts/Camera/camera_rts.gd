extends Node3D

@export var move_speed := 25.0
@export var edge_speed := 25.0

@export var zoom_speed := 2.0
@export var rotate_speed := 0.005

@export var edge_size := 20

@export var min_height := 8.0
@export var max_height := 35.0

@export var camera: Camera3D

var rotating := false


func _process(delta):

	var move = Vector3.ZERO

	# ===== WASD =====

	if Input.is_action_pressed("move_forward"):
		move.z -= 1

	if Input.is_action_pressed("move_back"):
		move.z += 1

	if Input.is_action_pressed("move_left"):
		move.x -= 1

	if Input.is_action_pressed("move_right"):
		move.x += 1

	if move != Vector3.ZERO:
		move = move.normalized()

		var forward = transform.basis.z
		var right = transform.basis.x

		global_position += (right * move.x + forward * move.z) * move_speed * delta


	# ===== Движение к краям экрана =====

	var mouse = get_viewport().get_mouse_position()
	var size = get_viewport().get_visible_rect().size

	var edge_move = Vector3.ZERO

	if mouse.x <= edge_size:
		edge_move.x -= 1

	if mouse.x >= size.x - edge_size:
		edge_move.x += 1

	if mouse.y <= edge_size:
		edge_move.z -= 1

	if mouse.y >= size.y - edge_size:
		edge_move.z += 1

	if edge_move != Vector3.ZERO:

		edge_move = edge_move.normalized()

		var forward = transform.basis.z
		var right = transform.basis.x

		var movement = right * edge_move.x + forward * edge_move.z

		global_position += movement * edge_speed * delta


func _unhandled_input(event):

	# ===== Вращение средней кнопкой =====

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			rotating = event.pressed

		if event.pressed:

			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.position.y -= zoom_speed

			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.position.y += zoom_speed

			camera.position.y = clamp(
				camera.position.y,
				min_height,
				max_height
			)

	# ===== Поворот камеры =====

	if event is InputEventMouseMotion and rotating:
		rotation.y -= event.relative.x * rotate_speed
