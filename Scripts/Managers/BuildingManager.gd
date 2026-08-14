extends Node

# IMPORTANT: No class_name here!
# This script is an Autoload named "BuildingManager".

var buildings: Array = []
var town_centers: Array = []


func register_building(building) -> void:
	if building == null:
		return

	if building not in buildings:
		buildings.append(building)

	if building is TownCenter:
		if building not in town_centers:
			town_centers.append(building)
		print("TownCenter registered: ", building.name)


func unregister_building(building) -> void:
	if building == null:
		return

	buildings.erase(building)
	town_centers.erase(building)


func get_nearest_town_center(from_position: Vector3):
	if town_centers.is_empty():
		return null

	var nearest = null
	var best_dist_sq := INF

	for tc in town_centers:
		if tc == null or not is_instance_valid(tc):
			continue

		var dist_sq: float = from_position.distance_squared_to(tc.global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			nearest = tc

	return nearest


func get_all_buildings() -> Array:
	return buildings
