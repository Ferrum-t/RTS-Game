extends Node

class_name SelectionManager

const MARKER_SCENE = preload("res://Scenes/Marker/marker.tscn")

@export var camera: Camera3D
@export var ground: StaticBody3D
@export var selection_box: Control
@export var interaction_manager: InteractionManager

var marker = null

var selected_units: Array[BaseUnit] = []


func _ready():

	marker = MARKER_SCENE.instantiate()
	add_child(marker)
	marker.visible = false

	selection_box.selection_finished.connect(_on_selection_finished)


func clear_selection():

	for unit in selected_units:
		unit.deselect()

	selected_units.clear()


func add_to_selection(unit: BaseUnit):

	if unit not in selected_units:

		selected_units.append(unit)
		unit.select()


func _unhandled_input(event):

	if event is InputEventMouseButton and event.pressed:

		var mouse_pos = get_viewport().get_mouse_position()

		var origin = camera.project_ray_origin(mouse_pos)
		var end = origin + camera.project_ray_normal(mouse_pos) * 5000.0

		var query = PhysicsRayQueryParameters3D.create(origin, end)

		var result = camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result:
			return

		var collider = result.collider

		# -------------------------
		# ЛКМ
		# -------------------------

		if event.button_index == MOUSE_BUTTON_LEFT:

			clear_selection()

			for unit in UnitManager.units:

				if collider == unit:
					add_to_selection(unit)

		# -------------------------
		# ПКМ
		# -------------------------

		elif event.button_index == MOUSE_BUTTON_RIGHT:

			interaction_manager.handle_right_click(
				selected_units,
				collider,
				result.position
			)

			marker.global_position = result.position
			marker.visible = true


func _on_selection_finished(selection: Rect2):

	if selection.size.length() < 8.0:
		return

	clear_selection()

	for unit in UnitManager.units:

		var screen_pos: Vector2 = camera.unproject_position(unit.global_position)

		if selection.has_point(screen_pos):

			add_to_selection(unit)
