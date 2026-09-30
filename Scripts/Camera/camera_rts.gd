extends Node3D

@export var move_speed := 25.0
@export var edge_speed := 25.0

@export var zoom_speed := 2.0
@export var rotate_speed := 0.005

@export var edge_size := 20

@export var min_height := 8.0
@export var max_height := 35.0

## Map playable bounds (XZ). 200×200 field with margin inside zone extremes.
@export var map_min_x: float = -95.0
@export var map_max_x: float = 95.0
@export var map_min_z: float = -95.0
@export var map_max_z: float = 95.0

## Player team for start focus (Warcraft-style).
@export var player_team_id: int = 0

@export var camera: Camera3D

var rotating := false


func _ready() -> void:
	# Defer so BuildingManager has registered player TC.
	call_deferred("_focus_player_town_center")


func _focus_player_town_center() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return
	var tc: Node3D = null
	if bm.has_method("get_nearest_town_center"):
		# Any player TC near origin; first registered is fine for start.
		tc = bm.get_nearest_town_center(Vector3.ZERO, player_team_id)
	if tc == null or not is_instance_valid(tc):
		# Fallback: scan registered list if exposed.
		var list: Array = bm.get("town_centers") if "town_centers" in bm else []
		for b in list:
			if b != null and is_instance_valid(b) and int(b.get("team_id")) == player_team_id:
				tc = b
				break
	if tc == null or not is_instance_valid(tc):
		return
	var p: Vector3 = tc.global_position
	global_position.x = p.x
	global_position.z = p.z
	_clamp_to_map()
	if OS.is_debug_build():
		print("[CAMERA] start focus on ", tc.name, " at (", snappedf(p.x, 0.1), ", ", snappedf(p.z, 0.1), ")")


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


	# ===== Edge scroll =====

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

	_clamp_to_map()


func _clamp_to_map() -> void:
	global_position.x = clampf(global_position.x, map_min_x, map_max_x)
	global_position.z = clampf(global_position.z, map_min_z, map_max_z)


func _unhandled_input(event):

	# ===== Middle-mouse rotate =====

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

	# ===== Camera yaw =====

	if event is InputEventMouseMotion and rotating:
		rotation.y -= event.relative.x * rotate_speed
