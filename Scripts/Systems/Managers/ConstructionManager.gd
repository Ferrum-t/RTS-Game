extends Node

var current_ghost: GhostBuilding = null
var current_building_data: BuildingData = null
var _place_serial: int = 0


func start_building(data: BuildingData) -> void:
	if data == null:
		return

	var cost: Dictionary = data.get_cost_dict()
	var rm := get_node_or_null("/root/ResourceManager")
	if rm and not rm.can_afford(cost):
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
	var cost: Dictionary = data.get_cost_dict()
	var rm := get_node_or_null("/root/ResourceManager")

	if rm:
		if not rm.spend(cost):
			print("Construction: not enough resources to place ", data.building_name)
			return

	var position := current_ghost.global_position

	if data.building_scene == null:
		push_error("Construction: building_scene is null")
		return

	var building = data.building_scene.instantiate()

	# Readable name for logs / AI (avoid @CharacterBody3D@N).
	_place_serial += 1
	var base_label: String = str(data.building_name).strip_edges()
	if base_label.is_empty():
		base_label = "Building"
	base_label = base_label.replace(" ", "")
	building.name = "%s_%d" % [base_label, _place_serial]

	# M6.8 A: set transform BEFORE add_child so BaseBuilding._ready / nav register
	# see the real placement position (World root is identity → position == global).
	building.position = position
	get_tree().current_scene.add_child(building)

	# M6.8 B: defensive footprint sync after node is in tree (live global_position).
	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav != null and nav.has_method("update_building_position"):
		nav.update_building_position(building)
	elif nav != null and nav.has_method("register_building"):
		var he := Vector3.ZERO
		if "nav_half_extents" in building:
			he = building.nav_half_extents
		nav.register_building(building, he)

	current_ghost.queue_free()
	current_ghost = null
	current_building_data = null

	print("Building placed: ", building.name,
		" (cost W:", data.wood, " S:", data.stone, ")",
		" at ", building.global_position)
