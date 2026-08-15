extends Node

var town_center: TownCenter = null


func register_building(building: BaseBuilding) -> void:
	if building is TownCenter:
		town_center = building
		print("TownCenter registered.")


func unregister_building(building: BaseBuilding) -> void:
	if building == town_center:
		town_center = null


func get_nearest_town_center(_position: Vector3) -> TownCenter:
	return town_center


func has_town_center() -> bool:
	return town_center != null
