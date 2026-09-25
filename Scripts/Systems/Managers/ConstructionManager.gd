extends Node

var current_ghost: GhostBuilding = null
var current_building_data: BuildingData = null
var _place_serial: int = 0
## M10.1 — Worker locked at start_building; must still be valid at confirm.
var _pending_builder: BaseUnit = null

const BUILD_APPROACH_DIST := 3.0


func is_placing() -> bool:
	return current_ghost != null and is_instance_valid(current_ghost)


func start_building(data: BuildingData) -> void:
	if data == null:
		return

	# M10.1: player construction only from a selected Worker.
	var builder := _first_selected_worker()
	if builder == null:
		print("Construction: select a Worker before placing ", data.building_name)
		return

	var cost: Dictionary = data.get_cost_dict()
	var rm := get_node_or_null("/root/ResourceManager")
	if rm and not rm.can_afford(cost, 0):
		print("Construction: not enough resources for ", data.building_name,
			" (need W:", data.wood, " S:", data.stone, " G:", data.gold, " F:", data.food, ")")
		return

	if current_ghost != null:
		current_ghost.queue_free()

	current_building_data = data
	_pending_builder = builder

	if data.ghost_scene == null:
		push_error("Construction: ghost_scene is null")
		_pending_builder = null
		return

	current_ghost = data.ghost_scene.instantiate()
	get_tree().current_scene.add_child(current_ghost)
	print("Started building mode: ", data.building_name, " builder=", builder.name)


## M10.1c — cancel placement only (no site, no spend).
func cancel_build_mode() -> void:
	var had_ghost: bool = current_ghost != null and is_instance_valid(current_ghost)
	if had_ghost:
		current_ghost.queue_free()
	current_ghost = null
	current_building_data = null
	_pending_builder = null
	if had_ghost:
		print("[BUILD] ghost cancelled (no site, no spend)")


func confirm_build() -> void:
	if current_ghost == null or current_building_data == null:
		return

	if not current_ghost.can_build:
		print("Can't build here.")
		return

	# M10.1: no site / no spend without a valid builder.
	var builder := _resolve_pending_builder()
	if builder == null:
		print("[BUILD] NO VALID BUILDER — placement cancelled (no spend)")
		cancel_build_mode()
		return

	var data := current_building_data
	var position := current_ghost.global_position

	# Player path: site under construction (AI keeps start_constructed=true default).
	var building := place_building_for_team(data, position, 0, false)
	if building == null:
		# spend failed or scene null — clear ghost
		cancel_build_mode()
		return

	current_ghost.queue_free()
	current_ghost = null
	current_building_data = null
	_pending_builder = null

	builder.replace_order_build(building as BaseBuilding)
	print("[BUILD] assigned ", builder.name, " → ", building.name)


## Stage 1 — programmatic placement used by player UI and Economic AI.
func place_building_for_team(
	data: BuildingData,
	world_pos: Vector3,
	team_id: int,
	start_constructed: bool = true
) -> Node:
	if data == null:
		return null
	if data.building_scene == null:
		push_error("Construction: building_scene is null")
		return null

	var cost: Dictionary = data.get_cost_dict()
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		if not rm.spend(cost, team_id):
			print(
				"Construction: team ", team_id,
				" cannot afford ", data.building_name,
				" (need W:", data.wood, " S:", data.stone, ")"
			)
			return null

	var building = data.building_scene.instantiate()
	_place_serial += 1
	var base_label: String = str(data.building_name).strip_edges()
	if base_label.is_empty():
		base_label = "Building"
	base_label = base_label.replace(" ", "")
	building.name = "%s_%d" % [base_label, _place_serial]
	if "team_id" in building:
		building.team_id = team_id

	building.position = world_pos
	var scene := get_tree().current_scene
	if scene == null:
		building.queue_free()
		return null
	scene.add_child(building)

	if not start_constructed and building is BaseBuilding:
		var bt: float = 25.0
		if data.build_time_sec > 0.0:
			bt = data.build_time_sec
		(building as BaseBuilding).begin_construction(bt)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav != null and nav.has_method("update_building_position"):
		nav.update_building_position(building)
	elif nav != null and nav.has_method("register_building"):
		var he := Vector3.ZERO
		if "nav_half_extents" in building:
			he = building.nav_half_extents
		nav.register_building(building, he)

	print(
		"Building placed: ", building.name,
		" team=", team_id,
		" constructed=", start_constructed,
		" (cost W:", data.wood, " S:", data.stone, ")",
		" at ", building.global_position
	)
	return building


func _resolve_pending_builder() -> BaseUnit:
	# Freed workers must be cleared before any typed BaseUnit call (Godot type-check throws).
	if _pending_builder != null and not is_instance_valid(_pending_builder):
		_pending_builder = null
	if _is_valid_builder(_pending_builder):
		return _pending_builder
	# Re-check selection once (worker may have been re-selected).
	var w := _first_selected_worker()
	if _is_valid_builder(w):
		_pending_builder = w
		return w
	_pending_builder = null
	return null


func _is_valid_builder(w) -> bool:
	## Untyped arg: previously-freed Object fails BaseUnit type check before body runs.
	if w == null or not is_instance_valid(w):
		return false
	if not (w is Worker):
		return false
	if int(w.team_id) != 0:
		return false
	if int(w.unit_state) == BaseUnit.UnitState.DEAD:
		return false
	return true


func _first_selected_worker() -> BaseUnit:
	var sm := get_node_or_null("/root/SelectionManager")
	if sm == null:
		var nodes := get_tree().get_nodes_in_group("selection_manager")
		if nodes.size() > 0:
			sm = nodes[0]
	if sm == null or not sm.has_method("get_valid_selection"):
		return null
	var selected: Array = sm.get_valid_selection()
	for u in selected:
		if u is Worker and is_instance_valid(u):
			var w: BaseUnit = u as BaseUnit
			if w.team_id == 0 and w.unit_state != BaseUnit.UnitState.DEAD:
				return w
	return null
