extends Node

class_name SelectionManager

const MARKER_SCENE = preload("res://Scenes/Marker/marker.tscn")

@export var camera: Camera3D
@export var ground: StaticBody3D
@export var selection_box: Control
@export var interaction_manager: InteractionManager

var marker: Node3D
# Используем Node, так как компоненты могут быть добавлены к любому объекту
var selected_units: Array[Node] = []

func _ready() -> void:
	if selection_box != null:
		selection_box.selection_finished.connect(_on_selection_finished)

	marker = MARKER_SCENE.instantiate()
	add_child(marker)
	marker.visible = false

func clear_selection() -> void:
	for unit in selected_units:
		if is_instance_valid(unit) and unit.has_method("deselect"):
			unit.deselect()
	selected_units.clear()

func add_to_selection(unit: Node) -> void:
	if unit == null:
		return
	# Duck typing: проверяем наличие метода перед вызовом
	if unit not in selected_units and unit.has_method("select"):
		selected_units.append(unit)
		unit.select()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if camera == null:
		return
	if not event.is_pressed():
		return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var end: Vector3 = origin + camera.project_ray_normal(mouse_pos) * 5000.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if not result:
		return

	var collider = result.collider
	if event.button_index == MOUSE_BUTTON_LEFT:
		clear_selection()
		# Выделяем, если объект поддерживает выделение
		if collider.has_method("select"):
			add_to_selection(collider)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		print("[DIAG] SelectionManager: Right-click on collider ", collider.name if collider else "null", " position ", result.position, " selected count ", selected_units.size())
		if interaction_manager != null:
			# Приводим массив Node к Array[BaseUnit] перед отправкой
			var units_as_base: Array[BaseUnit] = []
			for node in selected_units:
				if node is BaseUnit:
					units_as_base.append(node)
			print("[DIAG] SelectionManager: Sending ", units_as_base.size(), " BaseUnits to InteractionManager")
			interaction_manager.handle_right_click(units_as_base, collider, result.position)
		if marker != null:
			marker.global_position = result.position
			marker.visible = true


func _on_selection_finished(selection: Rect2) -> void:
	if selection.size.length() < 8.0:
		return
	if camera == null:
		return

	clear_selection()

	# Создаем форму для физического запроса на основе 4 углов рамки
	var world_3d := camera.get_world_3d()
	var space_state := world_3d.direct_space_state
	
	# Получаем лучи из 4 углов рамки
	var corners := [
		selection.position,
		selection.position + Vector2(selection.size.x, 0),
		selection.position + Vector2(0, selection.size.y),
		selection.position + selection.size
	]
	
	var points := [Vector3.ZERO] # Вершина пирамиды в камере
	for corner in corners:
		# Проецируем точку из экрана в мир (небольшое смещение от камеры)
		var ray_origin := camera.project_ray_origin(corner)
		var ray_dir := camera.project_ray_normal(corner)
		points.append(camera.to_local(ray_origin + ray_dir * 100.0))
	
	var query := PhysicsShapeQueryParameters3D.new()
	var shape := ConvexPolygonShape3D.new()
	shape.points = PackedVector3Array(points)
	
	query.shape = shape
	query.transform = camera.global_transform
	# Убедитесь, что в Collision Layers юнитов стоит 2-й слой (Units)
	query.collision_mask = 2 

	var result := space_state.intersect_shape(query)
	
	for hit in result:
		var collider = hit.collider
		if collider and collider.has_method("select"):
			add_to_selection(collider)
