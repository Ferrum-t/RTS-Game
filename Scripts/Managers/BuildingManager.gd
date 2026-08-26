extends Node

# Autoload — no class_name

var buildings: Array = []
var town_centers: Array = []
var barracks_list: Array = []


func register_building(building) -> void:
	if building == null:
		return

	if building not in buildings:
		buildings.append(building)

	if building is TownCenter:
		if building not in town_centers:
			town_centers.append(building)
		print("TownCenter registered: ", building.name)
	elif building is Barracks:
		if building not in barracks_list:
			barracks_list.append(building)
		print("Barracks registered: ", building.name)


func unregister_building(building) -> void:
	if building == null:
		return

	buildings.erase(building)
	town_centers.erase(building)
	barracks_list.erase(building)


## team_filter < 0 → any team; otherwise only matching team_id.
## Skips destroyed / zero-health buildings.
func get_nearest_town_center(from_position: Vector3, team_filter: int = -1):
	if town_centers.is_empty():
		return null

	var nearest = null
	var best_dist_sq := INF

	for tc in town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if tc.get("is_destroyed") == true:
			continue
		if tc.get("health") != null and int(tc.health) <= 0:
			continue
		if team_filter >= 0 and int(tc.team_id) != team_filter:
			continue
		var dist_sq: float = from_position.distance_squared_to(tc.global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			nearest = tc

	return nearest


func get_first_barracks():
	for b in barracks_list:
		if b != null and is_instance_valid(b):
			return b
	return null


func get_all_buildings() -> Array:
	return buildings
