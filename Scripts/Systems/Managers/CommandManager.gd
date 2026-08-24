extends Node

class_name CommandManager


func issue_move(units: Array[BaseUnit], position: Vector3) -> void:
	if not _match_allows_commands():
		return
	var valid: Array[BaseUnit] = _filter_valid(units)
	if valid.is_empty():
		return

	var targets: Array[Vector3] = Formation.generate_positions(position, valid.size())

	for i: int in range(valid.size()):
		valid[i].replace_order_move(targets[i])


func issue_harvest(units: Array[BaseUnit], resource: BaseResource) -> void:
	if not _match_allows_commands():
		return
	if resource == null or not is_instance_valid(resource):
		return
	for unit: BaseUnit in _filter_valid(units):
		if not TeamRules.can_harvest(unit, resource):
			continue
		unit.replace_order_harvest(resource)
		print(unit.name, " -> ", resource.name)


func issue_attack(units: Array[BaseUnit], enemy: BaseUnit) -> void:
	if not _match_allows_commands():
		return
	if enemy == null or not is_instance_valid(enemy):
		return
	if enemy.unit_state == BaseUnit.UnitState.DEAD:
		return
	for unit: BaseUnit in _filter_valid(units):
		if unit == enemy:
			continue
		if not TeamRules.can_attack(unit, enemy):
			continue
		unit.replace_order_attack(enemy)


func issue_attack_building(units: Array[BaseUnit], building: BaseBuilding) -> void:
	if not _match_allows_commands():
		return
	if building == null or not is_instance_valid(building):
		return
	if building.is_destroyed:
		return
	for unit: BaseUnit in _filter_valid(units):
		if not TeamRules.can_attack_building(unit, building):
			continue
		unit.replace_order_attack_building(building)


func _match_allows_commands() -> bool:
	var mm := get_node_or_null("/root/MatchManager")
	if mm == null:
		return true
	if mm.has_method("is_playing"):
		return mm.is_playing()
	return true


func _filter_valid(units: Array[BaseUnit]) -> Array[BaseUnit]:
	var out: Array[BaseUnit] = []
	for unit in units:
		if not TeamRules.can_command(unit):
			continue
		out.append(unit)
	return out
