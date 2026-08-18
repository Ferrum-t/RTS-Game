extends Node

class_name CommandManager


func issue_move(units: Array[BaseUnit], position: Vector3) -> void:
	var valid: Array[BaseUnit] = _filter_valid(units)
	if valid.is_empty():
		return

	var targets: Array[Vector3] = Formation.generate_positions(position, valid.size())

	for i: int in range(valid.size()):
		valid[i].replace_order_move(targets[i])


func issue_harvest(units: Array[BaseUnit], resource: BaseResource) -> void:
	if resource == null or not is_instance_valid(resource):
		return
	for unit: BaseUnit in _filter_valid(units):
		unit.replace_order_harvest(resource)
		print(unit.name, " -> ", resource.name)


func issue_attack(units: Array[BaseUnit], enemy: BaseUnit) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	if enemy.unit_state == BaseUnit.UnitState.DEAD:
		return
	for unit: BaseUnit in _filter_valid(units):
		if unit == enemy:
			continue
		unit.replace_order_attack(enemy)


func _filter_valid(units: Array[BaseUnit]) -> Array[BaseUnit]:
	var out: Array[BaseUnit] = []
	for unit in units:
		if unit == null:
			continue
		if not is_instance_valid(unit):
			continue
		if unit.unit_state == BaseUnit.UnitState.DEAD:
			continue
		out.append(unit)
	return out
