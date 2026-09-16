extends Node

var current_ghost: GhostBuilding = null
var current_building_data: BuildingData = null
var _place_serial: int = 0

const BUILD_APPROACH_DIST := 3.0


func start_building(data: BuildingData) -> void:
	if data == null:
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

	if data.ghost_scene == null:
		push_error("Construction: ghost_scene is null")
		return

	current_ghost = data.ghost_scene.instantiate()
	get_tree().current_scene.add_child(current_ghost)
	print("Started building mode: ", data.building_name)


func confirm_build() -> void:
	if current_ghost == null or current_building_data == null:
		return

	if not current_ghost.can_build:
		print("Can't build here.")
		return

	var data := current_building_data
	var position := current_ghost.global_position

	# Player path: site under construction (AI keeps start_constructed=true default).
	var building := place_building_for_team(data, position, 0, false)
	if building == null:
		return

	current_ghost.queue_free()
	current_ghost = null
	current_building_data = null

	_assign_builder(building as BaseBuilding)


## Stage 1 — programmatic placement used by player UI and Economic AI.
## start_constructed=true → immediately READY (AI / legacy).
## start_constructed=false → M10 construction site for player.
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


func _assign_builder(site: BaseBuilding) -> void:
	if site == null or not is_instance_valid(site):
		return
	var worker := _pick_builder_worker(site.global_position)
	if worker == null:
		print("[BUILD] no free Worker for ", site.name, " — site waits at progress=", site.construction_progress)
		return
	worker.replace_order_build(site)
	print("[BUILD] assigned ", worker.name, " → ", site.name)


func _pick_builder_worker(site_pos: Vector3) -> BaseUnit:
	# 1) Selected Worker team 0 (any non-DEAD)
	var sm := get_node_or_null("/root/SelectionManager")
	if sm != null and sm.has_method("get_valid_selection"):
		var selected: Array = sm.get_valid_selection()
		for u in selected:
			if u is Worker and is_instance_valid(u):
				var w: BaseUnit = u as BaseUnit
				if w.team_id == 0 and w.unit_state != BaseUnit.UnitState.DEAD:
					return w
	# 2) Nearest free Worker team 0
	var um := get_node_or_null("/root/UnitManager")
	if um == null:
		return null
	var best: BaseUnit = null
	var best_d := INF
	for u in um.units:
		if not (u is Worker) or not is_instance_valid(u):
			continue
		var w: BaseUnit = u as BaseUnit
		if w.team_id != 0:
			continue
		if not _is_worker_free(w):
			continue
		var d: float = w.global_position.distance_squared_to(site_pos)
		if d < best_d:
			best_d = d
			best = w
	return best


func _is_worker_free(w: BaseUnit) -> bool:
	if w == null or not is_instance_valid(w):
		return false
	match w.unit_state:
		BaseUnit.UnitState.DEAD:
			return false
		BaseUnit.UnitState.BUILDING:
			return false
		BaseUnit.UnitState.HARVESTING:
			return false
		BaseUnit.UnitState.RETURNING:
			return false
		BaseUnit.UnitState.ATTACKING:
			return false
		_:
			return true
