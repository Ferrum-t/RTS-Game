extends Node

class_name BuildingManager

var town_center: BaseBuilding = null


func register_building(building: BaseBuilding):

	if building is TownCenter:

		town_center = building

		print("TownCenter registered.")


func unregister_building(building: BaseBuilding):

	if building == town_center:

		town_center = null
