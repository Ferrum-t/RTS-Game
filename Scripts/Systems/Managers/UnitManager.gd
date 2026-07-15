extends Node

var units: Array[BaseUnit] = []


func register_unit(unit: BaseUnit) -> void:

	if unit not in units:

		units.append(unit)

		print("Registered:", unit.name)


func unregister_unit(unit: BaseUnit) -> void:

	units.erase(unit)
