extends Node

var current_ghost: GhostBuilding = null
var current_building_data: BuildingData = null
var is_building_mode := false


func start_building(data: BuildingData) -> void:
	print("ConstructionManager.start_building called")
	cancel_building()

	if data == null:
		push_error("Construction data is null")
		return
	if data.ghost_scene == null or data.building_scene == null:
		push_error("Building scene references are missing")
		return

	var town_center: TownCenter = BuildingManager.get_nearest_town_center(Vector3.ZERO)
	if town_center == null:
		if data.building_name == "Town Center":
			print("Starting first Town Center construction (no TownCenter registered yet).")
		else:
			print("Cannot start building: no TownCenter registered.")
			return

	if town_center != null:
		var cost: Dictionary = data.get_cost()
		print("Attempting to start building:", data.building_name, "cost=", cost, "stock=", town_center.stored_resources)
		if not town_center.can_afford(cost):
			print("Not enough resources to start building:", data.building_name)
			return
	else:
		print("Starting first Town Center build (free placement).")

	current_building_data = data
	current_ghost = data.ghost_scene.instantiate()
	get_tree().current_scene.add_child(current_ghost)
	is_building_mode = true
	print("Started building mode.")


func cancel_building() -> void:
	if current_ghost != null:
		current_ghost.queue_free()
		current_ghost = null
	current_building_data = null
	is_building_mode = false


func confirm_build() -> void:
	print("ConstructionManager.confirm_build called. mode=", is_building_mode, "ghost=", current_ghost, "build_data=", current_building_data)
	if not is_building_mode:
		return
	if current_ghost == null or current_building_data == null:
		cancel_building()
		return
	if not current_ghost.can_build:
		print("Can't build here.")
		return

	var town_center: TownCenter = BuildingManager.get_nearest_town_center(Vector3.ZERO)
	if town_center == null:
		if current_building_data.building_name == "Town Center":
			print("Placing first Town Center without TownCenter registered.")
		else:
			print("Cannot place building: no TownCenter registered.")
			return

	if town_center != null:
		var cost: Dictionary = current_building_data.get_cost()
		print("Attempting place building:", current_building_data.building_name, "cost=", cost, "stock=", town_center.stored_resources)
		if not town_center.spend_resources(cost):
			print("Not enough resources to place building:", current_building_data.building_name)
			return
	else:
		print("Placed first Town Center (free placement).")

	var position: Vector3 = current_ghost.global_position
	var building = current_building_data.building_scene.instantiate()
	get_tree().current_scene.add_child(building)
	building.global_position = position

	current_ghost.queue_free()
	current_ghost = null
	current_building_data = null
	is_building_mode = false
	print("Building placed.")
