extends RefCounted

class_name TeamRules

## M4/M5: pure team / ownership checks. Never mutates unit_state or orders.
## Intentionally untyped params — avoids parse cycle with BaseUnit class_name.

## Must match BaseUnit.UnitState.DEAD enum ordinal
const UNIT_STATE_DEAD := 6


static func local_team_id() -> int:
	return 0


static func can_select(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	if int(unit.unit_state) == UNIT_STATE_DEAD:
		return false
	return int(unit.team_id) == local_team_id()


static func can_attack(attacker, target) -> bool:
	if attacker == null or not is_instance_valid(attacker):
		return false
	if target == null or not is_instance_valid(target):
		return false
	if attacker == target:
		return false
	if int(attacker.unit_state) == UNIT_STATE_DEAD:
		return false
	if int(target.unit_state) == UNIT_STATE_DEAD:
		return false
	return int(attacker.team_id) != int(target.team_id)


static func can_attack_building(attacker, building) -> bool:
	if attacker == null or not is_instance_valid(attacker):
		return false
	if building == null or not is_instance_valid(building):
		return false
	if int(attacker.unit_state) == UNIT_STATE_DEAD:
		return false
	if building.get("is_destroyed") == true:
		return false
	if building.get("health") != null and int(building.health) <= 0:
		return false
	return int(attacker.team_id) != int(building.team_id)


static func can_harvest(_unit, resource) -> bool:
	return resource != null and is_instance_valid(resource)


static func can_command(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	return int(unit.unit_state) != UNIT_STATE_DEAD
