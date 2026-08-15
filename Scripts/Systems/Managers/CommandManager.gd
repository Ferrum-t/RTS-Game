extends Node

class_name CommandManager


func issue_move(units: Array[BaseUnit], position: Vector3) -> void:
	var targets: Array[Vector3] = Formation.generate_positions(position, units.size())

	for i: int in range(units.size()):
		units[i].set_move_target(targets[i])


func issue_harvest(units: Array[BaseUnit], resource: BaseResource) -> void:
	for unit: BaseUnit in units:
		unit.set_harvest_target(resource)
		print(unit.name, " -> ", resource.name)


func issue_attack(units: Array[BaseUnit], enemy: BaseUnit) -> void:
	for unit: BaseUnit in units:
		if unit == enemy:
			continue
		unit.set_attack_target(enemy)
