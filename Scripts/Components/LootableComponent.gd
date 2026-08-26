extends Node

class_name LootableComponent

## Phase 6 — raid loot siphon from building stock into attacker stockpile.
## Player-owned buildings (team_id 0) drain the global ResourceManager.
## Other teams use a virtual stock seeded at ready (no multi-RM yet).

@export var loot_ratio: float = 0.5
## Starting virtual stock for non-player teams (demo enemy economy).
@export var virtual_wood: int = 200
@export var virtual_stone: int = 50
@export var virtual_horses: int = 20

var _building: BaseBuilding = null
var _virtual: Dictionary = {} # BaseResource.Type -> int


func setup(building: BaseBuilding) -> void:
	_building = building
	if building == null:
		return
	if building.team_id != 0:
		_virtual = {
			BaseResource.Type.WOOD: virtual_wood,
			BaseResource.Type.STONE: virtual_stone,
			BaseResource.Type.HORSES: virtual_horses,
		}


func get_available(resource_type: int) -> int:
	if _building == null:
		return 0
	if _building.team_id == 0:
		var rm := get_node_or_null("/root/ResourceManager")
		if rm == null:
			return 0
		return int(rm.get_stock(resource_type))
	return int(_virtual.get(resource_type, 0))


func _take_from_owner(resource_type: int, amount: int) -> int:
	if amount <= 0:
		return 0
	var avail: int = get_available(resource_type)
	var taken: int = mini(amount, avail)
	if taken <= 0:
		return 0
	if _building.team_id == 0:
		var rm := get_node_or_null("/root/ResourceManager")
		if rm == null:
			return 0
		rm.remove(resource_type, taken)
	else:
		_virtual[resource_type] = avail - taken
	return taken


## Siphon loot proportional to damage into attacker ResourceManager (team 0 only credit for now).
## Returns Dictionary[BaseResource.Type, int] of amounts taken.
func extract_loot(damage_dealt: float, attacker_team_id: int) -> Dictionary:
	var result: Dictionary = {}
	if damage_dealt <= 0.0 or _building == null:
		return result

	var pool: float = damage_dealt * loot_ratio
	if pool < 0.5:
		# Accumulate fractional hits: at least try 0 until pool large enough via rounding
		pool = damage_dealt * loot_ratio

	var types: Array = [
		BaseResource.Type.WOOD,
		BaseResource.Type.STONE,
		BaseResource.Type.GOLD,
		BaseResource.Type.FOOD,
		BaseResource.Type.HORSES,
	]

	var total_avail: int = 0
	for t in types:
		total_avail += get_available(int(t))
	if total_avail <= 0:
		return result

	var remaining_pool: float = pool
	for t in types:
		var rt: int = int(t)
		var avail: int = get_available(rt)
		if avail <= 0:
			continue
		var share: float = float(avail) / float(total_avail)
		var want: int = int(floor(remaining_pool * share + 0.0001))
		# Guarantee at least 1 from largest piles when pool >= 1
		if want <= 0 and pool >= 1.0 and avail > 0 and share >= 0.2:
			want = 1
		var taken: int = _take_from_owner(rt, want)
		if taken > 0:
			result[rt] = taken
			remaining_pool = maxf(remaining_pool - float(taken), 0.0)

	# Credit attacker (player stockpile only in v1)
	if attacker_team_id == 0 and not result.is_empty():
		var rm := get_node_or_null("/root/ResourceManager")
		if rm:
			for key in result.keys():
				rm.add(int(key), int(result[key]))

	return result


func snapshot_stock() -> Dictionary:
	var snap: Dictionary = {}
	for t in [
		BaseResource.Type.WOOD,
		BaseResource.Type.STONE,
		BaseResource.Type.GOLD,
		BaseResource.Type.FOOD,
		BaseResource.Type.HORSES,
	]:
		var v: int = get_available(int(t))
		if v > 0:
			snap[int(t)] = v
	return snap


static func format_stock(stock: Dictionary) -> String:
	var parts: PackedStringArray = []
	if stock.has(BaseResource.Type.WOOD):
		parts.append("Wood: %d" % int(stock[BaseResource.Type.WOOD]))
	if stock.has(BaseResource.Type.STONE):
		parts.append("Stone: %d" % int(stock[BaseResource.Type.STONE]))
	if stock.has(BaseResource.Type.GOLD):
		parts.append("Gold: %d" % int(stock[BaseResource.Type.GOLD]))
	if stock.has(BaseResource.Type.FOOD):
		parts.append("Food: %d" % int(stock[BaseResource.Type.FOOD]))
	if stock.has(BaseResource.Type.HORSES):
		parts.append("Horses: %d" % int(stock[BaseResource.Type.HORSES]))
	if parts.is_empty():
		return "{}"
	return "{ " + ", ".join(parts) + " }"
