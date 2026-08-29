extends Node

class_name SelectionManager

const MARKER_SCENE = preload("res://Scenes/Marker/marker.tscn")
const MARKER_HEIGHT := 0.05
const MARKER_VISIBLE_TIME := 0.8

@export var camera: Camera3D
@export var ground: StaticBody3D
@export var selection_box: Control
@export var interaction_manager: InteractionManager

var marker: Node3D = null
var selected_units: Array[BaseUnit] = []
## Player MobileBuildings (TC / Watchtower) for individual pack/move/unpack.
var selected_buildings: Array = []
var _marker_timer: float = 0.0


func _ready() -> void:
	add_to_group("selection_manager")
	marker = MARKER_SCENE.instantiate()
	add_child(marker)
	marker.visible = false

	if selection_box:
		selection_box.selection_finished.connect(_on_selection_finished)


func _process(delta: float) -> void:
	if marker != null and marker.visible:
		_marker_timer -= delta
		if _marker_timer <= 0.0:
			marker.visible = false

	_prune_selection()


func clear_selection() -> void:
	for unit in selected_units:
		if is_instance_valid(unit):
			_disconnect_unit_exit(unit)
			unit.deselect()
	selected_units.clear()
	clear_building_selection()


func clear_building_selection() -> void:
	for b in selected_buildings:
		if is_instance_valid(b) and b.has_method("set_building_selected"):
			b.set_building_selected(false)
	selected_buildings.clear()


func add_to_selection(unit: BaseUnit) -> void:
	if not TeamRules.can_select(unit):
		return
	if unit in selected_units:
		return

	clear_building_selection()
	selected_units.append(unit)
	unit.select()
	_connect_unit_exit(unit)


func select_building(building: Node) -> void:
	if building == null or not is_instance_valid(building):
		return
	if not (building is MobileBuilding):
		return
	if int(building.get("team_id")) != 0:
		return
	if building.get("is_destroyed") == true:
		return

	# Exclusive: units XOR buildings
	for unit in selected_units:
		if is_instance_valid(unit):
			_disconnect_unit_exit(unit)
			unit.deselect()
	selected_units.clear()

	clear_building_selection()
	selected_buildings.append(building)
	if building.has_method("set_building_selected"):
		building.set_building_selected(true)
	print("Selected building: ", building.name, " state=", building.get("deployment_state"))


func get_valid_selection() -> Array[BaseUnit]:
	_prune_selection()
	return selected_units


func get_selected_mobile_buildings() -> Array:
	_prune_buildings()
	return selected_buildings


func _prune_selection() -> void:
	var alive: Array[BaseUnit] = []
	for unit in selected_units:
		if not is_instance_valid(unit):
			continue
		if unit.unit_state == BaseUnit.UnitState.DEAD:
			_disconnect_unit_exit(unit)
			continue
		if not TeamRules.can_select(unit):
			_disconnect_unit_exit(unit)
			unit.deselect()
			continue
		alive.append(unit)
	selected_units = alive
	_prune_buildings()


func _prune_buildings() -> void:
	var alive: Array = []
	for b in selected_buildings:
		if b == null or not is_instance_valid(b):
			continue
		if b.get("is_destroyed") == true:
			continue
		alive.append(b)
	selected_buildings = alive


func _connect_unit_exit(unit: BaseUnit) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	if not unit.tree_exiting.is_connected(_on_selected_unit_tree_exiting):
		unit.tree_exiting.connect(_on_selected_unit_tree_exiting.bind(unit))


func _disconnect_unit_exit(unit: BaseUnit) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	if unit.tree_exiting.is_connected(_on_selected_unit_tree_exiting):
		unit.tree_exiting.disconnect(_on_selected_unit_tree_exiting)


func _on_selected_unit_tree_exiting(unit: BaseUnit) -> void:
	selected_units.erase(unit)


func _place_marker_on_ground(world_pos: Vector3) -> void:
	if marker == null:
		return
	marker.global_position = Vector3(world_pos.x, MARKER_HEIGHT, world_pos.z)
	marker.visible = true
	_marker_timer = MARKER_VISIBLE_TIME


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if camera == null:
			return

		var mouse_pos := get_viewport().get_mouse_position()
		var origin := camera.project_ray_origin(mouse_pos)
		var end := origin + camera.project_ray_normal(mouse_pos) * 5000.0

		var query := PhysicsRayQueryParameters3D.create(origin, end)
		var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result:
			return

		var collider = result.collider

		if event.button_index == MOUSE_BUTTON_LEFT:
			clear_selection()
			# Prefer unit hit
			for unit in UnitManager.units:
				if not is_instance_valid(unit):
					continue
				if collider == unit:
					add_to_selection(unit)
					return
			# Player mobile building
			if collider is MobileBuilding and int(collider.get("team_id")) == 0:
				select_building(collider)
				return

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_prune_selection()
			if interaction_manager:
				interaction_manager.handle_right_click(
					selected_units,
					collider,
					result.position,
					selected_buildings
				)
			_place_marker_on_ground(result.position)


func _on_selection_finished(selection: Rect2) -> void:
	if selection.size.length() < 8.0:
		return

	clear_selection()

	for unit in UnitManager.units:
		if not is_instance_valid(unit):
			continue
		var screen_pos: Vector2 = camera.unproject_position(unit.global_position)
		if selection.has_point(screen_pos):
			add_to_selection(unit)
