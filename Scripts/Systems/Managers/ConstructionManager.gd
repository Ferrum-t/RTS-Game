extends Node

var current_ghost: GhostBuilding = null
var current_building_data: BuildingData = null


func start_building(data: BuildingData) -> void:
	if data == null:
		return

	var rm := get_node_or_null("/root/ResourceManager")
	if rm and not rm.can_afford(data.wood, data.stone, data.gold, data.food):
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
	var rm := get_node_or_null("/root/ResourceManager")

	if rm:
		if not rm.spend(data.wood, data.stone, data.gold, data.food):
			print("Construction: not enough resources to place ", data.building_name)
			return

	var position := current_ghost.global_position

	if data.building_scene == null:
		push_error("Construction: building_scene is null")
		return

	var building = data.building_scene.instantiate()
	get_tree().current_scene.add_child(building)
	building.global_position = position

	current_ghost.queue_free()
	current_ghost = null
	current_building_data = null

	print("Building placed: ", data.building_name,
		" (cost W:", data.wood, " S:", data.stone, ")")
