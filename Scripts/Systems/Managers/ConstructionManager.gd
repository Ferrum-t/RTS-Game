extends Node

## Construction placement + ghost. M10.1: player builds require valid Worker.

var current_ghost: Node3D = null
var current_building_data = null
var _place_serial: int = 0
var _pending_builder: BaseUnit = null

const BUILD_APPROACH_DIST := 3.0


func is_placing() -> bool:
	return current_ghost != null


func start_building(data) -> void:
	if data == null:
		return
	var builder := _first_selected_worker()
	if builder == null:
		print("[BUILD] start_building: no valid Worker selected")
		return
	if current_ghost != null:
		current_ghost.queue_free()
		current_ghost = null
	current_building_data = data
	_pending_builder = builder
	var ghost_scene = preload("res://Scenes/Buildings/GhostBuilding.tscn")
	current_ghost = ghost_scene.instantiate()
	if current_ghost.has_method("setup"):
		current_ghost.setup(data)
	get_tree().current_scene.add_child(current_ghost)
	print("[BUILD] Started building mode: ", data.building_name if data.get("building_name") else data)


func cancel_build_mode() -> void:
	var had_ghost := current_ghost != null
	if current_ghost != null:
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
		cancel_build_mode()
		return

	current_ghost.queue_free()
	current_ghost = null
	current_building_data = null
	_pending_builder = null

	builder.replace_order_build(building as BaseBuilding)
	print("[BUILD] assigned ", builder.name, " → ", building.name)


## Stage 1 — programmatic placement used by player UI and Economic AI.
func place_building_for_team(data, position: Vector3, team_id: int = 0, start_constructed: bool = true):
	if data == null:
		return null
	var rm := get_node_or_null("/root/ResourceManager")
	if rm != null and data.get("wood") != null:
		var cost_wood: int = int(data.wood) if data.get("wood") != null else 0
		var cost_stone: int = int(data.stone) if data.get("stone") != null else 0
		if cost_wood > 0 or cost_stone > 0:
			if not rm.can_afford(ResourceManager.make_cost(cost_wood, cost_stone), team_id):
				print("Not enough resources for ", data.get("building_name"), " team=", team_id)
				return null
			rm.spend(ResourceManager.make_cost(cost_wood, cost_stone), team_id)

	var scene: PackedScene = data.scene if data.get("scene") else null
	if scene == null:
		print("No scene for building data")
		return null

	var building = scene.instantiate()
	building.team_id = team_id
	building.global_position = position
	if start_constructed:
		if building.get("is_constructed") != null:
			building.is_constructed = true
	else:
		if building.has_method("begin_construction"):
			building.begin_construction()
		elif building.get("is_constructed") != null:
			building.is_constructed = false

	_place_serial += 1
	var base_name: String = str(data.get("building_name") if data.get("building_name") else building.get_class())
	building.name = "%s_%d" % [base_name.replace(" ", ""), _place_serial]

	var scene_root := get_tree().current_scene
	if scene_root:
		scene_root.add_child(building)
	else:
		add_child(building)

	print(
		"Building placed: ", building.name,
		" team=", team_id,
		" constructed=", start_constructed,
		" (cost W:", data.wood if data.get("wood") else 0, " S:", data.stone if data.get("stone") else 0, ")",
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
