extends RefCounted

class_name BuildingDamageRules

## Multipliers applied only when the target is a building.
const MELEE_VS_BUILDING: float = 0.25
const RANGED_VS_BUILDING: float = 0.10
const SIEGE_VS_BUILDING: float = 2.0


static func multiplier_for(damage_type: int) -> float:
	match damage_type:
		DamageType.Type.MELEE:
			return MELEE_VS_BUILDING
		DamageType.Type.RANGED:
			return RANGED_VS_BUILDING
		DamageType.Type.SIEGE:
			return SIEGE_VS_BUILDING
		_:
			return MELEE_VS_BUILDING


## Returns at least 1 if base_damage > 0 so melee still chips buildings.
static func modified_building_damage(base_damage: int, damage_type: int) -> int:
	if base_damage <= 0:
		return 0
	var mult: float = multiplier_for(damage_type)
	var result: int = int(round(float(base_damage) * mult))
	return maxi(result, 1)
