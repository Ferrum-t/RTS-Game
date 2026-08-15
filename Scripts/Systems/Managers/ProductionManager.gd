extends Node

class_name ProductionManager

func produce_unit(unit_data: UnitData) -> void:
	if unit_data == null:
		return

	var town_center: TownCenter = BuildingManager.get_nearest_town_center(Vector3.ZERO)
	if town_center == null:
		print("Cannot produce unit: no TownCenter registered.")
		return

	var cost: Dictionary = unit_data.get_cost()
	if not town_center.spend_resources(cost):
		print("Not enough resources to produce unit:", unit_data.unit_name)
		return

	var unit = unit_data.unit_scene.instantiate()
	if unit == null:
		print("Failed to instantiate unit scene for:", unit_data.unit_name)
		return

	get_tree().current_scene.add_child(unit)

	if unit is Node3D and town_center is Node3D:
		var spawn_position: Vector3 = town_center.global_position + Vector3(3.5, 0, 0)
		(unit as Node3D).global_position = spawn_position
	print("Produced unit:", unit_data.unit_name)
