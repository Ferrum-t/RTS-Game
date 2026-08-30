extends Node

var current_ghost: GhostBuilding = null
var current_building_data: BuildingData = null
var _place_serial: int = 0


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

	var building := place_building_for_team(data, position, 0)
	if building == null:
		return

	current_ghost.queue_free()
	current_ghost = null
	current_building_data = null


## Stage 1 — programmatic placement used by player UI and Economic AI.
## Same cost / instantiate / nav path; team_id owns the building and stock spend.
func place_building_for_team(data: BuildingData, world_pos: Vector3, team_id: int) -> Node:
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
		" (cost W:", data.wood, " S:", data.stone, ")",
		" at ", building.global_position
	)
	return building
