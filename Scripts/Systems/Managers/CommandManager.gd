extends Node

class_name CommandManager


func issue_move(
	units: Array[BaseUnit],
	position: Vector3
) -> void:
	if units.is_empty():
		return

	var targets: Array[Vector3] = Formation.generate_positions(
		position,
		units.size()
	)

	for i: int in range(units.size()):
		var unit: BaseUnit = units[i]
		if unit == null:
			continue

		var target_index: int = min(i, targets.size() - 1)
		unit.set_move_target(targets[target_index])


func issue_harvest(
	units: Array[BaseUnit],
	resource: BaseResource
) -> void:
	if resource == null:
		return

	for unit: BaseUnit in units:
		if unit == null:
			continue

		unit.set_harvest_target(resource)
		print(unit.name, " -> ", resource.name)


func issue_attack(
	units: Array[BaseUnit],
	target: Node
) -> void:
	if target == null:
		return

	for unit in units:
		if unit == null:
			continue

		var combat = unit.get_node_or_null("CombatComponent")
		if combat == null:
			combat = unit.get_node_or_null("Components/CombatComponent")

		if combat != null and combat.has_method("set_target"):
			combat.set_target(target)
			print(unit.name, " -> attacking ", target.name)
