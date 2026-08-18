extends Object

class_name TeamRules

## M4: pure team / ownership checks. Never mutates unit_state or orders.


static func local_team_id() -> int:
	return 0


static func can_select(unit: BaseUnit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	if unit.unit_state == BaseUnit.UnitState.DEAD:
		return false
	return unit.team_id == local_team_id()


static func can_attack(attacker: BaseUnit, target: BaseUnit) -> bool:
	if attacker == null or not is_instance_valid(attacker):
		return false
	if target == null or not is_instance_valid(target):
		return false
	if attacker == target:
		return false
	if attacker.unit_state == BaseUnit.UnitState.DEAD:
		return false
	if target.unit_state == BaseUnit.UnitState.DEAD:
		return false
	return attacker.team_id != target.team_id


static func can_harvest(_unit: BaseUnit, resource: BaseResource) -> bool:
	return resource != null and is_instance_valid(resource)


static func can_command(unit: BaseUnit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	return unit.unit_state != BaseUnit.UnitState.DEAD
